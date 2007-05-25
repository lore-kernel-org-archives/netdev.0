From: Clemens Brunner <clemens.brunner@tugraz.at>
Subject: Re: Link always down
Date: Fri, 25 May 2007 10:23:16 +0200
Message-ID: <46569CF4.2030108@tugraz.at>
References: <46557430.5060501@tugraz.at> <20070524120644.GA7224@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay.tu-graz.ac.at ([129.27.2.202]:52109 "EHLO
	mailrelay.tugraz.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009AbXEYJJa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 May 2007 05:09:30 -0400
In-Reply-To: <20070524120644.GA7224@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> It's known and it hits several P5B users. The 8168 works fine on a different
> motherboard though. It would be helpful if you could investigate the effect
> of the 8168 related options in your bios/and or in Windows (WOL, network
> boot, whatever) combined with the use of
> http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.22-rc2 on top of 2.6.22-rc2.

I've compiled and installed the latest kernel 2.6.22-rc2, but I wasn't able to 
apply your patch (using bzip2 -dc /usr/src/r8169-20070522.tar.bz2 | patch p1 
--dry-run yielded the message "Reversed (or previously applied) patch 
detected!", so I guess this patch was already included in the latest kernel 
source). Anyway, I started my system with the latest kernel, but I still got 
the same kernel message "r8169: eth0: link down".

In my BIOS, the only option related to the NIC is "LAN Option ROM" - this was 
disabled by default, so I enabled it, booted Linux, but the driver is still 
not working.

I don't know what else to try as there are no more BIOS options available. In 
Windows, the NIC is working with the Realtek driver from the company's 
website. I've tried the driver by Realtek, but I wasn't able to install the 
r1000 module, because modprobe r1000 said "FATAL: Error inserting r1000 
(/lib/modules/2.6.22-rc2-default/kernel/drivers/net/r1000.ko): Unknown symbol 
in module, or unknown parameter (see dmesg)". The unknown symbol was "r1000: 
Unknown symbol pci_module_init".

Clemens
