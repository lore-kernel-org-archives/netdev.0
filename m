From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Subject: [BUILD FAILURE]2.6.24-git6 build failure on sis190 ethernet driver
Date: Wed, 30 Jan 2008 09:11:36 +0530
Message-ID: <479FF1F0.10907@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	romieu@fr.zoreil.com, Andy Whitcroft <apw@shadowen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp04.in.ibm.com ([59.145.155.4]:48375 "EHLO
	e28esmtp04.in.ibm.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751741AbYA3Dls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 22:41:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The 2.6.24-git6 kernel build fails on various x86_64 machines with the build failure

drivers/net/sis190.c:329: error: sis190_pci_tbl causes a section type conflict
make[2]: *** [drivers/net/sis190.o] Error 1

# gcc --version (machine1)
gcc (GCC) 4.1.1 20070105 (Red Hat 4.1.1-52)

# gcc --version (machine2)
gcc (GCC) 4.1.1 20060525 (Red Hat 4.1.1-1)

-- 
Thanks & Regards,
Kamalesh Babulal,
Linux Technology Center,
IBM, ISTL.
