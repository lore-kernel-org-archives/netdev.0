From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: bonding driver - how to recognize the active slave
Date: Thu, 20 Dec 2012 13:19:30 -0800
Message-ID: <1356038370.21834.3315.camel@edumazet-glaptop>
References: <BA0B6857ABCA474FB07F0DA6F50A3077918B2450@MTRDAG01.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Erez Shitrit <erezsh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:47975 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751113Ab2LTVTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2012 16:19:33 -0500
Received: by mail-pa0-f43.google.com with SMTP id fb10so2365893pad.30
        for <netdev@vger.kernel.org>; Thu, 20 Dec 2012 13:19:33 -0800 (PST)
In-Reply-To: <BA0B6857ABCA474FB07F0DA6F50A3077918B2450@MTRDAG01.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-12-20 at 20:38 +0000, Erez Shitrit wrote:
> Hi,
> Is there any way to know who is the active slave in active-passive mode?
> 
> Is there any indication for that in netdevice flags? Or some other way?
> (I would like to get in my network interface driver which can be a slave of the bonding interface)
> 
> I saw that there is the flag IFF_SLAVE_INACTIVE but it is not used as far as I can see.


cat /sys/class/net/bond0/bonding/active_slave
