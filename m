From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: network namespace ipv6 perfs
Date: Mon, 03 Mar 2008 21:01:18 +0100
Message-ID: <47CC590E.5070907@fr.ibm.com>
References: <47CC0920.6000005@fr.ibm.com> <47CC53C9.1000400@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Containers <containers@lists.osdl.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:52754 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753681AbYCCUDq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 15:03:46 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.8/8.13.8) with ESMTP id m23K3juN252642
	for <netdev@vger.kernel.org>; Mon, 3 Mar 2008 20:03:45 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m23K3i7t1134658
	for <netdev@vger.kernel.org>; Mon, 3 Mar 2008 21:03:44 +0100
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m23K3ieT009784
	for <netdev@vger.kernel.org>; Mon, 3 Mar 2008 20:03:44 GMT
In-Reply-To: <47CC53C9.1000400@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rick Jones wrote:
> Daniel Lezcano wrote:
>> Hi,
>>
>> Some performance tests was made by Benjamin to watch out the impact of 
>> the network namespace. The good news is there is no impact when used 
>> with or without namespaces. That has been checked using a real network 
>> device inside a network namespace.
> 
> The *_RR tests seem to show a drop in througput and corresponding 
> increases in service demand - could that be because things like TSO et 
> al cannot mask much of anything in the way of a path-length increase?

Hmm. In fact Benjamin took the 2.6.23.16 kernel where there were no 
network namespace code at all. So these differences between 2.6.23.16 
and 2.6.25-rc1 does not show a performance degradation especially 
related to the network namespaces. The important point is the 2.6.25-rc1 
without ipv6 netns and 2.6.25-rc1 with ipv6 netns code applied, I mean 
the second and the third line and we can point that the ipv6 netns code 
does not degrade performances for either throughput and service demand.

>  From the annotations, I'm ass-u-me-ing that NS was only used on the 
> netperf side and not both netperf and netserver side?

right :)

> happy benchmarking,

Thanks Rick.

   -- Daniel
