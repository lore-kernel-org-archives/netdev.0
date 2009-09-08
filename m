From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: Adding bridge interface to non-default network namespace crashes
 kernel
Date: Tue, 08 Sep 2009 10:40:44 +0200
Message-ID: <4AA6188C.1070806@free.fr>
References: <200909071807.54511.atis@mikrotik.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
To: Atis Elsts <atis@mikrotik.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.17.162]:53923 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753907AbZIHIkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2009 04:40:45 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.1/8.13.1) with ESMTP id n888elVJ011472
	for <netdev@vger.kernel.org>; Tue, 8 Sep 2009 08:40:47 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n888el1U2502814
	for <netdev@vger.kernel.org>; Tue, 8 Sep 2009 10:40:47 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n888ekms023110
	for <netdev@vger.kernel.org>; Tue, 8 Sep 2009 10:40:47 +0200
In-Reply-To: <200909071807.54511.atis@mikrotik.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Atis Elsts wrote:
> Trying to add bridge interface from userspace program, after moving the 
> program to a new network namespace, causes kernel to crash. I am using latest 
> kernel version from git (2.6.31-rc9).
> The bug is easy to reproduce - just compile and run the attached C program.
>
> I see that bridge interface has NETIF_F_NETNS_LOCAL flag, but as I understand, 
> this flag simply means that a device cannot be *moved* across network 
> namespaces, not that it cannot be *created* in other namespaces.
>   
Yep, very easy to reproduce :/
The sysfs has not been disabled for the bridge. I will try to fix it as 
soon as I can.

Thanks
  -- Daniel
