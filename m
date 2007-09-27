From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH 3/4] net ipv4: When possible test for IFF_LOOPBACK and
 not dev == loopback_dev
Date: Thu, 27 Sep 2007 12:34:36 +0200
Message-ID: <46FB873C.6060200@fr.ibm.com>
References: <m1ps05rnjv.fsf@ebiederm.dsl.xmission.com> <m1ir5xrngu.fsf@ebiederm.dsl.xmission.com> <m1bqbprnc2.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, urs@isnogud.escape.de
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:59537 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750857AbXI0Ki4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 06:38:56 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.8/8.13.8) with ESMTP id l8RAcqan072432
	for <netdev@vger.kernel.org>; Thu, 27 Sep 2007 10:38:52 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8RAcqTZ1917010
	for <netdev@vger.kernel.org>; Thu, 27 Sep 2007 12:38:52 +0200
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8RAcpJ4023825
	for <netdev@vger.kernel.org>; Thu, 27 Sep 2007 12:38:52 +0200
In-Reply-To: <m1bqbprnc2.fsf_-_@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> Now that multiple loopback devices are becoming possible it makes
> the code a little cleaner and more maintainable to test if a deivice
> is th a loopback device by testing dev->flags & IFF_LOOPBACK instead
> of dev == loopback_dev.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>


Urs Thuermann posted the patch:

	[PATCH 5/7] CAN: Add virtual CAN netdevice driver

This network driver set its flag to IFF_LOOPBACK for testing.
Is it possible this can be a collision with your patch ?

