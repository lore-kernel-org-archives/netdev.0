From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Fix FRTO+NewReno problem (Was: Re: This has a work around)
Date: Thu, 8 May 2008 23:42:21 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805082336440.31776@wrl-59.cs.helsinki.fi>
References: <48207F06.50306@damtek.com> <Pine.LNX.4.64.0805061912350.8965@wrl-59.cs.helsinki.fi>
 <4821C37A.7040306@damtek.com> <Pine.LNX.4.64.0805072357240.23091@wrl-59.cs.helsinki.fi>
 <4823437D.20005@damtek.com>
Mime-Version: 1.0
Content-Type: MULTIPART/Mixed; boundary="=_courier-13210-1210270579-0001-2"
Cc: Bug 213081 <213081@bugs.launchpad.net>, 478062@bugs.debian.org,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: "Damon L. Chesser" <damon@damtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:53603 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757374AbYEHUmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2008 16:42:35 -0400
In-Reply-To: <4823437D.20005@damtek.com>
Content-ID: <Pine.LNX.4.64.0805082336441.31776@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--=_courier-13210-1210270579-0001-2
Content-Type: TEXT/PLAIN; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0805082336442.31776@wrl-59.cs.helsinki.fi>

On Thu, 8 May 2008, Damon L. Chesser wrote:

> Ilpo Järvinen wrote:
> > SNIP
> 
> >
> > Could you next try with tcp_frto set to 1, if my theory proves to be
> > correct, it too should be "enough" to fix the problem (in this particular
> > case). Of course you can verify the patch below too if you want to, the
> > patch should allow cups<->printer to work with tcp_frto = 2 too. In case you
> > have problem to apply the patch to the particular version you're want to try
> > with, just send a note about the version number to me so I can adapt the
> > patch for you (space etc. formatting issues may show up because I recently
> > run a code style cleanup on the tcp code).
>
> reran the print job with the correct kernel (for control reasons) and received
> the same results:  tcp_frto=1 no print.  tcp_frto=0 I can print.  Attached is
> the output of tcpdump
> 
> uname -r = 2.6.24-1-amd64

Well, that was a surprise, there must be something else too I didn't yet 
notice. I don't think it's that necessary for you to test that patch I 
sent earlier (basically the code paths it would have fixed were already in 
use with tcp_frto=1). And that patch was "obviously correct" anyway though 
it wasn't enough to fix this issue.

...I too can probably reproduce this locally with small amount of work 
because the receiver pattern is dead obvious from the logs.

-- 
 i.
--=_courier-13210-1210270579-0001-2--
