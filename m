From: Jar <jar@pcuf.fi>
Subject: Re: [PATCH 1/5] new pcmcia IDs for hostap - ASUS WL-110
Date: Sat, 13 May 2006 13:43:53 +0300
Message-ID: <4465B869.3020801@pcuf.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mbox2.netikka.net ([213.250.81.203]:58306 "EHLO
	mbox2.netikka.net") by vger.kernel.org with ESMTP id S932309AbWEMKnz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 May 2006 06:43:55 -0400
Received: from netlandzone.dyndns.org (p74.ip3.netikka.fi [85.157.67.74])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mbox2.netikka.net (Postfix) with ESMTP id ED4CE40808C
	for <netdev@vger.kernel.org>; Sat, 13 May 2006 13:43:53 +0300 (EEST)
Received: from [192.168.0.33] (gto.netland.fin [192.168.0.33])
	by netlandzone.dyndns.org (8.13.6/8.13.4) with ESMTP id k4DAhrV4027474
	for <netdev@vger.kernel.org>; Sat, 13 May 2006 13:43:53 +0300
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Roskin wrote:
 >I strongly believe that every driver should list all devices it can
 >support.  In case of multiple drivers supporting one device, the choice
 >should be done in userspace.

Just from end user's standpoint:

I am totally bored with this "model". Every time new kernel comes I 
first delete all orinoco drivers, because I can't even blacklist them. I 
don't want to use them, I have a better driver -->hostap. When I try to 
do the following in the /etc/modprobe.d/blacklist-custom :

# a) Do NOT load orinoco_pci/plx when we are using hostap driver
# b) Do NOT load eepro100, 8139cp

blacklist orinoco_pci
blacklist orinoco_plx

blacklist eepro100
blacklist 8139cp

The eepro100 and 8139cp get blacklisted just fine but not the 
orinoco_pci, it always want to load itself.

Because of this and the lack of WPA support in orinoco drivers the 
prism2 id:s should be removed from the orinoco drivers. To achieve 
security you have to run vpn over wireless when you use orinoco drivers.

How the orinoco driver can be as _good_ as the hostap driver for the 
prism2 cards? I think hostap is a lot better.

-- 
Best Regards, Jar
