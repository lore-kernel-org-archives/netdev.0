From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: kernel BUG at net/core/dev.c:1383 skb_checksum_help: BUG_ON(offset
 > (int)skb->len)
Date: Mon, 15 Oct 2007 13:15:05 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0710151311540.3767@kivilampi-30.cs.helsinki.fi>
References: <20071006141506.785a6683@localhost.localdomain>
 <20071014192640.35065e73@inria.fr> <Pine.LNX.4.64.0710151251090.3767@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-834525788-1192443155=:3767"
Cc: Netdev <netdev@vger.kernel.org>
To: Guillaume Chazarain <guichaz@yahoo.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:57295 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756134AbXJOKPG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 06:15:06 -0400
In-Reply-To: <Pine.LNX.4.64.0710151251090.3767@kivilampi-30.cs.helsinki.fi>
Content-ID: <Pine.LNX.4.64.0710151314530.3767@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-834525788-1192443155=:3767
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0710151314531.3767@kivilampi-30.cs.helsinki.fi>

On Mon, 15 Oct 2007, Ilpo Järvinen wrote:

> >         prior_in_flight = 4111991984
> 
> This one doesn't look very sane number... But it may well be ok due to 
> some compiler trick (dunno)... Just for completeness, could you print 
> tcp_sock contents too so I could briefly have a look (though I suspect 
> that the problem is elsewhere), thanks...

...Never mind, noticed the fix later on.

-- 
 i.
---696243703-834525788-1192443155=:3767--
