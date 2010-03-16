From: Blaschka <frank.blaschka@de.ibm.com>
Subject: question regarding hw tx csum for IPv6
Date: Tue, 16 Mar 2010 10:11:49 +0100
Message-ID: <20100316091149.GA2680@tuxmaker.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.17.165]:46547 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932662Ab0CPJLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 05:11:50 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.1/8.13.1) with ESMTP id o2G9Bn6S000846
	for <netdev@vger.kernel.org>; Tue, 16 Mar 2010 09:11:49 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2G9Bnq41433772
	for <netdev@vger.kernel.org>; Tue, 16 Mar 2010 10:11:49 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o2G9BnRw028500
	for <netdev@vger.kernel.org>; Tue, 16 Mar 2010 10:11:49 +0100
Received: from tuxmaker.boeblingen.de.ibm.com (tuxmaker.boeblingen.de.ibm.com [9.152.85.9])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id o2G9Bnh5028497
	for <netdev@vger.kernel.org>; Tue, 16 Mar 2010 10:11:49 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

for me it looks like many network drivers exclude IPv6 frames from
tx hw csum in case they have extended IPv6 headers. 
Does the stack generates the csum for this kind of frames anyhow
the device claims to do NETIF_F_HW_CSUM?

Thanks for any help
	Frank
