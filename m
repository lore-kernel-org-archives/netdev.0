From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Wed, 11 Jun 2008 16:39:57 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0806111636330.16829@wrl-59.cs.helsinki.fi>
References: <20080526115628.GA31316@elte.hu>  <Pine.LNX.4.64.0805312119270.2672@wrl-59.cs.helsinki.fi>
  <a01a16b50805311325w7f58ca69h93d02af9bc28d2ea@mail.gmail.com>
 <Pine.LNX.4.64.0805312332270.2760@wrl-59.cs.helsinki.fi>
 <a01a16b50806031710u54b9297bkf1fad9c4f8fd581f@mail.gmail.com>
 <Pine.LNX.4.64.0806041402211.16829@wrl-59.cs.helsinki.fi>
 <a01a16b50806040700h1efce63cq2a27b087df0d25be@mail.gmail.com>
 <Pine.LNX.4.64.0806041802360.2580@wrl-59.cs.helsinki.fi>
 <a01a16b50806060232u1eff3867u24fecc539fda1d14@mail.gmail.com>
 <Pine.LNX.4.64.0806091422180.16829@wrl-59.cs.helsinki.fi>
 <a01a16b50806101626i2942ebam462410ad26050829@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-292146203-1213191597=:16829"
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>
To: "=?UTF-8?Q?H=C3=A5kon_L=C3=B8vdal?=" <hlovdal@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33866 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750699AbYFKNkB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2008 09:40:01 -0400
In-Reply-To: <a01a16b50806101626i2942ebam462410ad26050829@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-292146203-1213191597=:16829
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 11 Jun 2008, Håkon Løvdal wrote:

> 2008/6/9 Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>:
> > ...also the one from allfiles.zip is similarily damaged.
> >
> > ...If you don't have an explanation, them it might be time to check
> > your hardware....
>
> I do not have any good explanation (bad memory?). When checking the
> copytest003.capture.bz2 file in the http server storage directory
> I get the same results as you. However I also have the original file
> stored still and comparing them with cmp -l gives
>  20558656 124 104
> so obviously a bit has been flipped.

...Yeah, which is a bad thing because now we don't know if that same error 
causes the TCP stops too.

> I have now replaced the erroneous file with a good copy, so you should 
> be able to download again.

I'll have a look if there's some common denominator but this whole issue 
might well be due to hw failure.


-- 
 i.
---696208474-292146203-1213191597=:16829--
