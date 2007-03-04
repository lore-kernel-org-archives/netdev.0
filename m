From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Wifi support for iproute2
Date: Sat, 3 Mar 2007 19:53:24 -0800
Message-ID: <20070303195324.75eed906@deepthought>
References: <20070304012653.GA9587@hooker.hq.c3d2.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephan Maka <stephan@spaceboyz.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:53077 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750763AbXCDDyG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Mar 2007 22:54:06 -0500
In-Reply-To: <20070304012653.GA9587@hooker.hq.c3d2.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 4 Mar 2007 02:26:53 +0100
Stephan Maka <stephan@spaceboyz.net> wrote:

> Hello
> 
> I've always felt uncomfortable by the usability of the wireless-tools
> (iwconfig, iwlist), but I really love iproute2. That's why I started
> to implement "ip wifi".
> 
> My GIT tree is located at:
>   http://cthulhu.c3d2.de/~astro/git/iproute2.git/
> 
> I wonder if this has a chance to get merged in iproute2 somewhen at
> all, or if this is completely inappropriate functionality for this
> tool.
> 
> Note that this my first contribution to a Linux-specific tool, *any*
> hints about style and conventions demanded here are welcome.
> 
> I'm sure not everyone will use this instead of wireless-tools, and a
> few even don't want it compiled in and linked with iwlib. Should I
> make this optional through a Makefile variable?
> 
> If noone else contributes not all of wireless-tools will be
> implemented, it's just too much. But basic stuff for configuring a
> Wifi card is already there.
> 
> Everyone told me dscape is near, but I hope iwlib will be ported then.

Don't waste your time with a tool that uses the exist wext API.
But a tool that could use cfg80211 would be useful. After the wireless
summit in Jan, I put it on my "interesting ideas" list.
