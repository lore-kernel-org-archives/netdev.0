From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: Cannot delete a bridge using 'ip' netlink interface
Date: Sat, 08 Oct 2011 00:37:11 +0400
Message-ID: <4E8F62F7.4080408@msgid.tls.msk.ru>
References: <1317921532.6433.13.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	netdev <netdev@vger.kernel.org>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([86.62.121.231]:40682 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934769Ab1JGUhN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Oct 2011 16:37:13 -0400
In-Reply-To: <1317921532.6433.13.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06.10.2011 21:18, Sridhar Samudrala wrote:
> On a linux 3.1.0-rc9 system using the latest iproute2, i tried
> creating a bridge and deleting it with an attached interface. 
> 
> Here is the sequence of steps i tried
> ip link add br0 type bridge
> ip link set dev eth1 master br0
> ip link set br0 up
> ip link del br0
> 
> The last command hangs with the following kernel messages
> kernel:unregister_netdevice: waiting for br0 to become free. Usage count = 1

Note that the same thing happens when one tries to rmmod bridge
while it is in use.  I'm trying your patch to see if that helps... ;)

/mjt
