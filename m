From: Mike Qiu <qiudayu@linux.vnet.ibm.com>
Subject: BCM5719(tg3) use multiple MSI with RSS
Date: Wed, 15 May 2013 15:56:59 +0800
Message-ID: <51933FCB.4090402@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eilong@broadcom.com, mchan@broadcom.com, mcarlson@broadcom.com,
	zambrano@broadcom.com, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp06.au.ibm.com ([202.81.31.148]:39775 "EHLO
	e23smtp06.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757048Ab3EOH5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 May 2013 03:57:22 -0400
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <qiudayu@linux.vnet.ibm.com>;
	Wed, 15 May 2013 17:50:48 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 08B9C2BB0050
	for <netdev@vger.kernel.org>; Wed, 15 May 2013 17:57:06 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4F7uw1i19005600
	for <netdev@vger.kernel.org>; Wed, 15 May 2013 17:56:58 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4F7v4KD032272
	for <netdev@vger.kernel.org>; Wed, 15 May 2013 17:57:05 +1000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all

Currently, I need to enable multiple MSI on BCM5719 network card.
But I look in to the spec of 5719 from Broadcom, it seems
that RSS just enable with MSI-X, so I'm not sure if multiple
MSI can use RSS.



And if multiple MSI can't use RSS, how other usage of the
interrupts allocated from the system? Can they be used to
improve the performance of the network?

Thanks
Mike
