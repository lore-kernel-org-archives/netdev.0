From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: two other cases Re: [Bug 11721] after upgrade to 2.6.27 i	cannot
 navigate
Date: Tue, 21 Oct 2008 13:51:10 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0810211333290.7072@wrl-59.cs.helsinki.fi>
References: <20081021090002.21e64151@topolino> <Pine.LNX.4.64.0810211200170.7072@wrl-59.cs.helsinki.fi>
 <20081021100923.GD4715@ff.dom.local>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1543215815-1224586270=:7072"
Cc: Aldo Maggi <sentiniate@tiscali.it>,
	Netdev <netdev@vger.kernel.org>, bugme-daemon@bugzilla.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:48855 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752702AbYJUKv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 06:51:29 -0400
In-Reply-To: <20081021100923.GD4715@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1543215815-1224586270=:7072
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Tue, 21 Oct 2008, Jarek Poplawski wrote:

> On Tue, Oct 21, 2008 at 12:36:33PM +0300, Ilpo Järvinen wrote:
> ...
> > Can you try this another debug patch below (on 2.6.27.2 is fine). It moves 
> > the mss to the last position but should keep timestamps in place by making 
> > wscale as first option. It is well possible that you won't get it working 
> > at all except with all ts,sack and wscale set to 0 (the most likely 
> > result). Please try with all wscale,sack,ts combinations (no need to 
> > provide dumps, just working/not working per case)... This should 
> > tell us for quite high certaintity what is the actual option which is 
> > causing this (would it not be the mss-at-beginning which is the most 
> > likely cause), [...]
> 
> I'd like to remind it seems to work with only sack off, so mss after
> ts. If so, my suspicion would be around rfc's/options' dating?

Thanks, I missed that case... there are so many cases already... :-)
...I'm not sure we'll find some very obvious reason for this, rfc dating 
probably has very little to do here.

I still think that putting an alternative option in front is useful test 
(though my initial mss-at-beginning thought wasn't bullet-proof) but 
maybe we could skip all those alternative settings of wscale,sack,ts and 
have them just all enabled.


-- 
 i.
---696208474-1543215815-1224586270=:7072--
