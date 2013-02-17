From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: Universal tap device
Date: Sun, 17 Feb 2013 10:35:20 +0100
Message-ID: <20130217093520.GA1931@minipsycho.orion>
References: <20130216140132.GB1536@minipsycho.orion>
 <alpine.LNX.2.01.1302161743180.8831@nerf07.vanv.qr>
 <20130216165430.GC1536@minipsycho.orion>
 <201302162225.06536.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Engelhardt <jengelh@inai.de>, netdev@vger.kernel.org,
	ebiederm@xmission.com, stephen@networkplumber.org,
	eric.dumazet@gmail.com, davem@davemloft.net
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f49.google.com ([74.125.83.49]:58199 "EHLO
	mail-ee0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755406Ab3BQJfY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Feb 2013 04:35:24 -0500
Received: by mail-ee0-f49.google.com with SMTP id d4so2392932eek.22
        for <netdev@vger.kernel.org>; Sun, 17 Feb 2013 01:35:23 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <201302162225.06536.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Feb 16, 2013 at 11:25:06PM CET, arnd@arndb.de wrote:
>On Saturday 16 February 2013, Jiri Pirko wrote:
>> Sat, Feb 16, 2013 at 05:46:25PM CET, jengelh@inai.de wrote:
>> >On Saturday 2013-02-16 15:01, Jiri Pirko wrote:
>> >
>> >>Hi all.                                                                  
>> >>                                                                         
>> >>Looking at macvtap and thinking about the tap solutions in general,
>> >>I think it would be handly to have some universal tap device.
>> >
>> >As in, allowing tuntap to register as an rx_handler for arbitrary
>> >devices?
>> 
>> Essentially yes, but I was thinking without the actual netdev:
>> not eth0 -> tap0 -> chardev
>> but eth0 -> chardev
>> 
>> Not sure though if that is easily doable..
>
>Isn't that the same as setting up macvtap in PASSTHRU mode?

Yep, but without netdev instance. That brings some issues. Maybe the
netdev instance should be there. Not sure.

>
>	Arnd
