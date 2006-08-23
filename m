From: Victor Secarin <vsecarin@paradigmgeo.com>
Subject: eth interface enumeration order
Date: Wed, 23 Aug 2006 09:52:56 -0600
Message-ID: <44EC79D8.3050402@paradigmgeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-207-148-171-98.gen.cadvision.com ([207.148.171.98]:34606 "EHLO
	pokey.corelab-rtd.ca") by vger.kernel.org with ESMTP
	id S964999AbWHWPxJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:53:09 -0400
To: akpm@zip.com.au, jgarzik@pobox.com, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

VERSION
With kernel 2.4.33.1:
HARDWARE
 I have a server with two eepro100 and one e1000 interfaces
BEHAVIOR
When the kernel boots the drivers report (/var/log/messages) the 
interfaces they find and what they are named (eth0, eth1, eth2)
1. With the drivers configured monolithically in the kernel:
e1000 reports eth0 and then eepro100 reports eth1 and eth2
2. With the drivers configured as modules:
eepro100 reports eth0 and eth1 and then e1000 reports eth2
PROBLEM
1. On a red  hat distribution, different interfaces may have different 
configuration scripts, which assign IP addresses and more, and the 
scripts are identified by the ethx name.
2. It is necessary to control which interface becomes eth0 as various 
programs use the MAC address of eth0 to identify the computer. In my 
case that is "lmhostid" and all the FLEXlm software,
as I run a license server on that machine.

Thank you for taking the time to read this.
yours truly,
Victor Secarin

