From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: eth interface enumeration order
Date: Wed, 23 Aug 2006 10:36:51 -0700
Message-ID: <20060823103651.193311dc@localhost.localdomain>
References: <44EC79D8.3050402@paradigmgeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@zip.com.au, jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:61651 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932324AbWHWRhK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 13:37:10 -0400
To: Victor Secarin <vsecarin@paradigmgeo.com>
In-Reply-To: <44EC79D8.3050402@paradigmgeo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 23 Aug 2006 09:52:56 -0600
Victor Secarin <vsecarin@paradigmgeo.com> wrote:

> VERSION
> With kernel 2.4.33.1:
> HARDWARE
>  I have a server with two eepro100 and one e1000 interfaces
> BEHAVIOR
> When the kernel boots the drivers report (/var/log/messages) the 
> interfaces they find and what they are named (eth0, eth1, eth2)
> 1. With the drivers configured monolithically in the kernel:
> e1000 reports eth0 and then eepro100 reports eth1 and eth2
> 2. With the drivers configured as modules:
> eepro100 reports eth0 and eth1 and then e1000 reports eth2
> PROBLEM
> 1. On a red  hat distribution, different interfaces may have different 
> configuration scripts, which assign IP addresses and more, and the 
> scripts are identified by the ethx name.
> 2. It is necessary to control which interface becomes eth0 as various 
> programs use the MAC address of eth0 to identify the computer. In my 
> case that is "lmhostid" and all the FLEXlm software,
> as I run a license server on that machine.
> 
> Thank you for taking the time to read this.
> yours truly,
> Victor Secarin

Depending on interface names and ordering is wrong, you will get burned.
Modern distro's with 2.6 use udev and scripts to control naming.

For older systems, see ifrename(8)

-- 
Stephen Hemminger <shemminger@osdl.org>

All non-trivial abstractions, to some degree, are leaky.
