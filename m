From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: NIC driver r8168 with r8169 for RTL8111/8168B and DGE-528T
 together
Date: Wed, 20 Jul 2011 12:22:06 -0700
Message-ID: <20110720122206.73898673@nehalam.ftrdhcpuser.net>
References: <4E26B198.4020606@telkomsa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Danie Wessels <dawessels@telkomsa.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34511 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752063Ab1GTTWI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 15:22:08 -0400
In-Reply-To: <4E26B198.4020606@telkomsa.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Jul 2011 12:44:40 +0200
Danie Wessels <dawessels@telkomsa.net> wrote:

> I would like to use my onboard NIC (eth0) with its r8168 driver from 
> RealTek together with my D-Link NIC (eth4=eth1) with its r8169 default 
> driver from the install.

The kernel developers do not support the use of out of tree
vendor drivers. If there is some reason the default kernel driver does
not work for your hardware, that is a bug that should be reported and
it will get fixed.
