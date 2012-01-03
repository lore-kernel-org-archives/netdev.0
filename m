From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp: detect loss above high_seq in recovery
Date: Tue, 3 Jan 2012 21:11:11 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1201032059570.28487@melkinpaasi.cs.helsinki.fi>
References: <1325033182-25905-1-git-send-email-ycheng@google.com> <alpine.DEB.2.00.1112281736480.7752@melkinpaasi.cs.helsinki.fi> <CAK6E8=fu_KAnzMhKYa368BzhGkLGtjjPhvDUezQ_b6Nsd5o6Zw@mail.gmail.com> <alpine.DEB.2.00.1112301256060.15137@wel-95.cs.helsinki.fi>
 <CAK6E8=eJU0puyqWsJg-7FESMEdHZgx3FXCMkxM7+rUyrSg1Hdg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-1590063589-1325617871=:28487"
Cc: David Miller <davem@davemloft.net>, ncardwell@google.com,
	nanditad@google.com, Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:40198 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754589Ab2ACTLM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 14:11:12 -0500
In-Reply-To: <CAK6E8=eJU0puyqWsJg-7FESMEdHZgx3FXCMkxM7+rUyrSg1Hdg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1590063589-1325617871=:28487
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Tue, 3 Jan 2012, Yuchung Cheng wrote:

> On Fri, Dec 30, 2011 at 3:19 AM, Ilpo Järvinen
> <ilpo.jarvinen@helsinki.fi> wrote:
> > On Thu, 29 Dec 2011, Yuchung Cheng wrote:
> >
> >> To summarize:
> >> 1) this change does NOT forbid TCP performing further CWR on new losses
> >> 2) this change (merely) marks some forward-retransmitted packets LOST.
> >> 3) the commit message is to be explicit that CWR may not always be performed,
> >>     in both my change and current kernel.
> >
> > I agree with these points. I wonder if you intend to look to fixing the
> > lacking CWR problem or should I look to that once I get some spare time?
> >
> >> HTH. I will update commit message if people can make sense of it :)
> >
> > Please do.
> Great, I'll update the commit message first, and work on another
> feature patch that does CWR if
> a) new sequence is lost
> b) a retransmission is lost

Ok, thanks. I think that it's better to do the way you suggest... ie., to 
do the cwr on detection rather than (possibly much) later when 
rexmitting.

-- 
 i.
--8323329-1590063589-1325617871=:28487--
