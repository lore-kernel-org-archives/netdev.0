From: Chuck Lever <chuck.lever@oracle.com>
Subject: RealTek 8169 support question
Date: Fri, 10 Aug 2007 17:27:47 -0400
Message-ID: <46BCD853.1010801@oracle.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000403090400060300050603"
To: romieu@fr.zoreil.com, netdev ML <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:19674 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750791AbXHJV2l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:28:41 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000403090400060300050603
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hello Francois-

I just bought a new Jetway mainboard with a pair of RTL 8169 NICs. 
After installing Fedora 7, and upgrading to 2.6.22.1-41.fc7, I still 
can't get either of the NICs to recognize a link beat from my switch.

lspci -v output:

00:09.0 Ethernet controller: Realtek Semiconductor Co., Ltd. 
RTL-8110SC/8169SC Gigabit Ethernet (rev 10)
         Subsystem: Jetway Information Co., Ltd. Unknown device 10ec
         Flags: bus master, 66MHz, medium devsel, latency 32, IRQ 18
         I/O ports at ee00 [size=256]
         Memory at fdffe000 (32-bit, non-prefetchable) [size=256]
         [virtual] Expansion ROM at 10020000 [disabled] [size=64K]
         Capabilities: [dc] Power Management version 2

00:0b.0 Ethernet controller: Realtek Semiconductor Co., Ltd. 
RTL-8110SC/8169SC Gigabit Ethernet (rev 10)
         Subsystem: Jetway Information Co., Ltd. Unknown device 10ec
         Flags: bus master, 66MHz, medium devsel, latency 32, IRQ 19
         I/O ports at f000 [size=256]
         Memory at fdffd000 (32-bit, non-prefetchable) [size=256]
         [virtual] Expansion ROM at 10030000 [disabled] [size=64K]
         Capabilities: [dc] Power Management version 2

I assume "Unknown device" indicates that the driver doesn't recognize 
the model string?

Thanks in advance for any advice.

--------------000403090400060300050603
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
url:http://oss.oracle.com/~cel
version:2.1
end:vcard


--------------000403090400060300050603--
