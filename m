From: Tino Reichardt <list-linux-netdev@mcmilk.de>
Subject: Re: [PATCHSET v1 00/07] Support for byte queue limits on various
 network interfaces
Date: Mon, 14 Oct 2013 20:46:09 +0200
Message-ID: <20131014184608.GA23070@mcmilk.de>
References: <1381775183-24866-1-git-send-email-milky-kernel@mcmilk.de>
 <20131014114117.5808e665@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lotte.svc-box.de ([80.252.109.10]:36582 "EHLO lotte.svc-box.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757033Ab3JNSz5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Oct 2013 14:55:57 -0400
Received: from localhost (localhost [127.0.0.1])
	by lotte.svc-box.de (Postfix) with ESMTP id 61F7A14801FA
	for <netdev@vger.kernel.org>; Mon, 14 Oct 2013 20:46:14 +0200 (CEST)
Received: from lotte.svc-box.de ([127.0.0.1])
	by localhost (lotte.svc-box.de [127.0.0.1]) (amavisd-new, port 10026)
	with ESMTP id D-hc8I83KTCt for <netdev@vger.kernel.org>;
	Mon, 14 Oct 2013 20:46:09 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <20131014114117.5808e665@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Stephen Hemminger <stephen@networkplumber.org> wrote:
> On Mon, 14 Oct 2013 20:26:16 +0200
> Tino Reichardt <milky-kernel@mcmilk.de> wrote:
> 
> > Hello,
> > 
> > this patchset adds support for byte queue limits for various network drivers.
> > 
> > These drivers are used as WAN interface on servers that I am managing. So
> > it would be nice, if support for BQL / codel for these drivers will make it
> > into the mainline... @ some time ;)
> > 
> > 
> > Any comments are welcome, thanks.
> > Tino Reichardt
> 
> How many of these have been tested on real devices?
> BQL has a nasty way of exposing bugs.

Currently the only one tested is the realtek t8169 for about two weeks.

All other hardware (except via-velocity) will get tested by me in near
future. But maybe other will also test these patches, so I put them to
the list.


-- 
Best regards, TR
