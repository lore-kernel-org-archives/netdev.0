From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp: Increase the initial congestion window to 10.
Date: Fri, 4 Feb 2011 21:50:03 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1102042143310.28937@melkinpaasi.cs.helsinki.fi>
References: <20110202.170750.229739784.davem@davemloft.net> <alpine.DEB.2.00.1102040027060.25125@melkinpaasi.cs.helsinki.fi> <AANLkTi=Zxp3VGt266MZ+NVmSFQhtnmUxPBFV_t2hcObZ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-458968332-1296849003=:28937"
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, therbert@google.com,
	"H.K. Jerry Chu" <hkjerry.chu@gmail.com>,
	Nandita Dukkipati <nanditad@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:52828 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752180Ab1BDTuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Feb 2011 14:50:05 -0500
In-Reply-To: <AANLkTi=Zxp3VGt266MZ+NVmSFQhtnmUxPBFV_t2hcObZ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-458968332-1296849003=:28937
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Thu, 3 Feb 2011, Yuchung Cheng wrote:

> On Thu, Feb 3, 2011 at 2:43 PM, Ilpo Järvinen <ilpo.jarvinen@helsinki.fi> wrote:
> > It would perhaps be useful to change receiver advertized window to include
> > some extra segs initially. It should be >= IW + peer's dupThresh-1 as
> That's a very good point.
> 
> Maybe IRW should be IW + ssthresh - 1 since Linux also performs
> limited-transmit during fast-recovery as described in RFC 3517. This
> way sender can keep sending new data during the recovery as long as
> cwnd allows.

You're of course right, I forgot the recovery altogether :-).

-- 
 i.
--8323329-458968332-1296849003=:28937--
