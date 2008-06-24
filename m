From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH] iproute2: add support for IFLA_NET_NS_PID in ip link
 v2
Date: Tue, 24 Jun 2008 11:35:39 +0200
Message-ID: <4860BFEB.2000807@fr.ibm.com>
References: <20080620090734.144305411@theryb.frec.bull.fr> <20080620092109.551812772@theryb.frec.bull.fr> <485F59ED.2080404@fr.ibm.com> <20080623090212.760589de@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Benjamin Thery <benjamin.thery@bull.net>, netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:45134 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751245AbYFXJgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2008 05:36:08 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.8/8.13.8) with ESMTP id m5O9a45o096222
	for <netdev@vger.kernel.org>; Tue, 24 Jun 2008 09:36:04 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5O9ZpJD573552
	for <netdev@vger.kernel.org>; Tue, 24 Jun 2008 11:35:53 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5O9ZmX3014179
	for <netdev@vger.kernel.org>; Tue, 24 Jun 2008 11:35:48 +0200
In-Reply-To: <20080623090212.760589de@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Mon, 23 Jun 2008 10:08:13 +0200
> Daniel Lezcano <dlezcano@fr.ibm.com> wrote:
> 
>> Benjamin Thery wrote:
>>> Ah, ah, of course I forgot to refresh the patch before sending it. :)
>>> There was still a small typo in the patch: a '}' was put instead of 
>>> a '|' in 'ip link' usage string. 
>>>
>>> Here is the updated patch.
>>> Sorry for this.
>>>
>>> Benjamin
>>>
>>> Description:
>>> ------------
>>>
>>> This patch adds support for the IFLA_NET_NS_PID type. It is used to 
>>> move network devices between network namespaces.
>>>
>>> The syntax is: 
>>> ip link set DEVICE netns PID
>>>
>>> PID is the pid of a process in the target network namespace.
>>>
>>> (Daniel Lezcano is the original author). 
>>>
>>> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
>>> Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
>> Hi Stephen,
>>
>> we posted this patch several times and we had no response.
>> I suppose you are very busy and you had no time to answer.
>> Can you briefly tell us what do you plan to do with this patch ?
>>
>>
>> Thanks
>>    -- Daniel
>>
> I am doing a new release. It is in the list of things to go in.
> But was holding off until other issues resolved. It will go in today.

Thanks Stephen.
