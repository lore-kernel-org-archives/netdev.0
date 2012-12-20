From: Erez Shitrit <erezsh@mellanox.com>
Subject: bonding driver - how to recognize the active slave
Date: Thu, 20 Dec 2012 20:38:36 +0000
Message-ID: <BA0B6857ABCA474FB07F0DA6F50A3077918B2450@MTRDAG01.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:58476 "HELO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751675Ab2LTUij convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2012 15:38:39 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
Is there any way to know who is the active slave in active-passive mode?

Is there any indication for that in netdevice flags? Or some other way?
(I would like to get in my network interface driver which can be a slave of the bonding interface)

I saw that there is the flag IFF_SLAVE_INACTIVE but it is not used as far as I can see.

Thanks, Erez
