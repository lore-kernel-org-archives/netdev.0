From: VinX <vincenx@fastwebnet.it>
Subject: Error acx-20060215 wireless module
Date: Fri, 14 Jul 2006 18:08:46 +0200
Message-ID: <44B7C18E.2070306@fastwebnet.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from aa003msr.fastwebnet.it ([85.18.95.66]:748 "EHLO
	aa003msr.fastwebnet.it") by vger.kernel.org with ESMTP
	id S1161140AbWGNP7D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jul 2006 11:59:03 -0400
Received: from theconfessional.redirectme.net (23.251.157.101) by aa003msr.fastwebnet.it (7.2.070.1)
        id 44A8F36D006D8AD1 for netdev@vger.kernel.org; Fri, 14 Jul 2006 17:58:59 +0200
Received: from [10.0.0.50] (laptopo.theconfessional.redirectme.net [10.0.0.50])
	by theconfessional.redirectme.net (Postfix) with ESMTP id DC12738E57C
	for <netdev@vger.kernel.org>; Fri, 14 Jul 2006 18:07:59 +0200 (CEST)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
on my gentoo with kernel 2.6.18-rc1 I had this error:
--
   CC [M]  /var/tmp/portage/acx-0.3.35/work/pci.o
/var/tmp/portage/acx-0.3.35/work/pci.c: In function `acxpci_e_probe':
/var/tmp/portage/acx-0.3.35/work/pci.c:1652: error: `UTS_RELEASE' 
undeclared (first use in this function)
/var/tmp/portage/acx-0.3.35/work/pci.c:1652: error: (Each undeclared 
identifier is reported only once
/var/tmp/portage/acx-0.3.35/work/pci.c:1652: error: for each function it 
appears in.)
make[1]: *** [/var/tmp/portage/acx-0.3.35/work/pci.o] Error 1
--
I think that it's missing <linux/utsrelease.h> on this file!

Best Regards,
VinX
