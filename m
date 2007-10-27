From: Yanko Kaneti <yaneti@declera.com>
Subject: ASUS NX1001 (IP100A, sundance) PHY not powered up
Date: Sat, 27 Oct 2007 16:04:06 +0300
Message-ID: <1193490246.12874.25.camel@indigo.declera.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, sorbica@icplus.com.tw, jesse@icplus.com.tw
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from indigo.declera.com ([212.116.131.21]:51787 "HELO
	indigo.declera.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752727AbXJ0NKs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Oct 2007 09:10:48 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Trying a new ASUS NX1001 adapter (1043:8213) with a IP100A chip
(13f0:0200) (rev 31) on a machine running Fedora development (2.6.23.1 +
some unrelated to sundance patches). 

On power up the link appears down (judging by the switch port its
connected to).  The normal fedora startup has udev which loads the
sundance driver, dmesg says it has done so, the link still down.
rmmod sundance - still down.
modprobe sundance - still down.
rmmod sundance - link up
modprobe sundance - link down
rmmod sundance - link up
..
?
All these with no indication of error in the logs.

Same make adapter from the same batch appears to function under win2k
after loading the driver from the cd.  Again the link appears to be
powered up when the driver is loaded.

The LED on the card is only active on data activity not link status. 

Puzzled
Yanko

