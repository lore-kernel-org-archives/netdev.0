From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: Universal tap device
Date: Sat, 16 Feb 2013 17:54:30 +0100
Message-ID: <20130216165430.GC1536@minipsycho.orion>
References: <20130216140132.GB1536@minipsycho.orion>
 <alpine.LNX.2.01.1302161743180.8831@nerf07.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, arnd@arndb.de, ebiederm@xmission.com,
	stephen@networkplumber.org, eric.dumazet@gmail.com,
	davem@davemloft.net
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f171.google.com ([209.85.215.171]:61264 "EHLO
	mail-ea0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753065Ab3BPQyf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2013 11:54:35 -0500
Received: by mail-ea0-f171.google.com with SMTP id c13so1925686eaa.16
        for <netdev@vger.kernel.org>; Sat, 16 Feb 2013 08:54:33 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.01.1302161743180.8831@nerf07.vanv.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Feb 16, 2013 at 05:46:25PM CET, jengelh@inai.de wrote:
>On Saturday 2013-02-16 15:01, Jiri Pirko wrote:
>
>>Hi all.                                                                  
>>                                                                         
>>Looking at macvtap and thinking about the tap solutions in general,
>>I think it would be handly to have some universal tap device.
>
>As in, allowing tuntap to register as an rx_handler for arbitrary
>devices?

Essentially yes, but I was thinking without the actual netdev:
not eth0 -> tap0 -> chardev
but eth0 -> chardev

Not sure though if that is easily doable..
