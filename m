From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: unloading the ipv6 module
Date: Thu, 26 Feb 2009 14:22:12 +0100
Message-ID: <49A69784.6070204@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:65524 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753414AbZBZNWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 08:22:31 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.14.3/8.13.8) with ESMTP id n1QDMT3l153252
	for <netdev@vger.kernel.org>; Thu, 26 Feb 2009 13:22:29 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n1QDMNW71200282
	for <netdev@vger.kernel.org>; Thu, 26 Feb 2009 14:22:24 +0100
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n1QDMDaP007024
	for <netdev@vger.kernel.org>; Thu, 26 Feb 2009 14:22:13 +0100
Received: from mai-009101017029.toulouse-stg.fr.ibm.com (dhcp0.lab.toulouse-stg.fr.ibm.com [9.101.4.200])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id n1QDMB8D007002
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 26 Feb 2009 14:22:13 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I saw in net/ipv6/Kconfig a comment saying
"IPv6 as module will cause a CRASH if you try to unload it".

If I refer to this comment, that means unloading of ipv6 is not 
supported (which makes sense),
will it be one day supported?

 -- Daniel
