From: Jar <jar@pcuf.fi>
Subject: Re: Remove Prism II support from Orinoco
Date: Tue, 13 Jun 2006 21:24:49 +0300
Message-ID: <448F02F1.3070001@pcuf.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mbox1.netikka.net ([213.250.81.202]:22659 "EHLO
	mbox1.netikka.net") by vger.kernel.org with ESMTP id S932212AbWFMSYx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jun 2006 14:24:53 -0400
Received: from netlandzone.dyndns.org (p74.ip3.netikka.fi [85.157.67.74])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mbox1.netikka.net (Postfix) with ESMTP id 02534270664
	for <netdev@vger.kernel.org>; Tue, 13 Jun 2006 21:24:51 +0300 (EEST)
Received: from [192.168.0.33] (gto.netland.fin [192.168.0.33])
	by netlandzone.dyndns.org (8.13.6/8.13.4) with ESMTP id k5DIOnZb006529
	for <netdev@vger.kernel.org>; Tue, 13 Jun 2006 21:24:51 +0300
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:

 >use blacklist in module config to block one.
 >Just put in /etc/modprobe.conf

 >blacklist orinoco

Unfortunately this is not work at least it is not work with FC4. I can 
blacklist eepro100 and 8139cp.

blacklist eepro100
blacklist 8139cp

but I can't blacklist orinoco_pci
blacklist orinoco_pci

It always loads itself with or without blacklist. That's why I have to 
do 'rm -f orinoco*.* && depmod -a' when the new kernel arrives. Seems 
that users are directed to use unsecure orinoco (wep) driver rather than 
secure hostap (wpa/wpa2,tkip,aes) driver for their prism2 hardware.

-- 
Best Regards, Jar
