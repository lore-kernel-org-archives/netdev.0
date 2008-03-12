From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH][NEIGH]: Fix race between pneigh deletion and ipv6's ndisc_recv_ns
 - V2
Date: Wed, 12 Mar 2008 11:41:50 +0100
Message-ID: <47D7B36E.5060104@fr.ibm.com>
References: <47CFD2ED.3060207@openvz.org> <47D68817.9030709@openvz.org> <20080311.175212.74407707.davem@davemloft.net> <47D7A52D.2090007@fr.ibm.com> <47D7B0C3.1010801@openvz.org> <47D7B131.9060607@fr.ibm.com> <47D7B31F.40800@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	=?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:8847 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765AbYCLKnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2008 06:43:35 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.13.8/8.13.8) with ESMTP id m2CAhXka419550
	for <netdev@vger.kernel.org>; Wed, 12 Mar 2008 10:43:33 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2CAhXus1990686
	for <netdev@vger.kernel.org>; Wed, 12 Mar 2008 11:43:33 +0100
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2CAhUVY030713
	for <netdev@vger.kernel.org>; Wed, 12 Mar 2008 11:43:33 +0100
In-Reply-To: <47D7B31F.40800@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
> Daniel Lezcano wrote:
>> Pavel Emelyanov wrote:
>>> Daniel Lezcano wrote:
>>>> David Miller wrote:
>>>>> From: Pavel Emelyanov <xemul@openvz.org>
>>>>> Date: Tue, 11 Mar 2008 16:24:39 +0300
>>>>>
>>>>>> You picked up the patch with /proc/net symlink, but skipped this
>>>>>> one, while it was sent earlier. Is it _that_ bad :) ?
>>>>> I am travelling and giving presentations in Japan, and
>>>>> this patch is in my backlog to look at :-)
>>>> The patch does not apply anymore due to the ndisc modification to be per 
>>>> namespace. I modified it to take the namespace into account and 
>>>> initialized the is_router variable to avoid a compilation warning.
>>>>
>>> My patch applies to net-2.6, while yours does not. 
>>> Which tree is it for?
>> well, hum, net-2.6.26 :|
> 
> OK. 
> Then I will fix the comments from YOSHIFUJI and re-send the patch for net-2.6.

Ok, sorry for the confusion.
