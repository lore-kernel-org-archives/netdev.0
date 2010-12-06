From: Olof Johansson <olof@lixom.net>
Subject: Re: [RFC] mark devices with broken LRO implementation
Date: Mon, 6 Dec 2010 11:18:16 -0600
Message-ID: <20101206171816.GA25568@lixom.net>
References: <1291653582-14177-1-git-send-email-leitao@linux.vnet.ibm.com> <20101206084824.637d6b29@nehalam> <4CFD15F6.7040609@linux.vnet.ibm.com> <20101206091010.036cd78b@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Breno Leitao <leitao@linux.vnet.ibm.com>,
	Eli Cohen <eli@dev.mellanox.co.il>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.lixom.net ([70.86.134.90]:44993 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753086Ab0LFRZy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Dec 2010 12:25:54 -0500
Content-Disposition: inline
In-Reply-To: <20101206091010.036cd78b@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 06, 2010 at 09:10:10AM -0800, Stephen Hemminger wrote:
> The kernel uses dev_disable_lro to disable Large Receive Offload
> for cases where it is inappropriate. But several drivers do not implement
> the required hook.  This is a "penalty box" patch to encourage those
> drivers to add support for the necessary ethtool set_flags.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

pasemi_mac:

Acked-by: Olof Johansson <olof@lixom.net>

> I only found three drivers that are broken. Normally, I would just fix
> them; but since changing state in the device is hardware specific, and
> I don't have the hardware or specs to do anything useful to fix it.

Thanks. All my hardware is currently in storage due to my relocation, but
I'll take a look at it when I have something to run on back. :-)


-Olof

