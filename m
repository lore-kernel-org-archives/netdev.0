From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: Universal tap device
Date: Sat, 16 Feb 2013 22:25:06 +0000
Message-ID: <201302162225.06536.arnd@arndb.de>
References: <20130216140132.GB1536@minipsycho.orion> <alpine.LNX.2.01.1302161743180.8831@nerf07.vanv.qr> <20130216165430.GC1536@minipsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jan Engelhardt <jengelh@inai.de>, netdev@vger.kernel.org,
	ebiederm@xmission.com, stephen@networkplumber.org,
	eric.dumazet@gmail.com, davem@davemloft.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:58692 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754537Ab3BPWZs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2013 17:25:48 -0500
In-Reply-To: <20130216165430.GC1536@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 16 February 2013, Jiri Pirko wrote:
> Sat, Feb 16, 2013 at 05:46:25PM CET, jengelh@inai.de wrote:
> >On Saturday 2013-02-16 15:01, Jiri Pirko wrote:
> >
> >>Hi all.                                                                  
> >>                                                                         
> >>Looking at macvtap and thinking about the tap solutions in general,
> >>I think it would be handly to have some universal tap device.
> >
> >As in, allowing tuntap to register as an rx_handler for arbitrary
> >devices?
> 
> Essentially yes, but I was thinking without the actual netdev:
> not eth0 -> tap0 -> chardev
> but eth0 -> chardev
> 
> Not sure though if that is easily doable..

Isn't that the same as setting up macvtap in PASSTHRU mode?

	Arnd
