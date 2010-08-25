From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [net-next 2/2] macvlan:  Enable qdisc backoff logic.
Date: Wed, 25 Aug 2010 21:59:11 +0200
Message-ID: <201008252159.11227.arnd@arndb.de>
References: <1282762851-3612-1-git-send-email-greearb@candelatech.com> <201008252124.09917.arnd@arndb.de> <4C756EAF.9090704@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:60346 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751536Ab0HYT7N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 15:59:13 -0400
In-Reply-To: <4C756EAF.9090704@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 25 August 2010 21:27:43 Ben Greear wrote:
> > I suppose we need to do something in macvtap to handle this as
> > well, right? A guest trying to send a frame through qemu
> > or vhost net into macvtap needs to be prevented from sending
> > more when we get into this path. Right now, we just ignore
> > the return value of macvlan_start_xmit.
> 
> I have a similar, though slightly more complex, patch for 802.1q
> vlans, but I haven't looked at macvtap at all.
> 
> If these two patches are accepted, I'll post the .1q patch as well.

I think one of us needs to fix macvtap in order for your patch to
go in, because otherwise there is a memory leak or worse when
macvtap fails to retransmit the frame.

	Arnd
