From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: why does promote_secondaries default to off?
Date: Fri, 11 Jan 2008 18:33:23 +0100
Message-ID: <4787A863.3060506@fr.ibm.com>
References: <20080111163155.GA17637@piper.oerlikon.madduck.net> <4787A3AB.4000205@fr.ibm.com> <20080111172641.GA22449@piper.oerlikon.madduck.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev discussion list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:17878 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761690AbYAKRdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 12:33:37 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate4.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m0BHXYjT086626
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 17:33:34 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0BHXYxs5058794
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 17:33:34 GMT
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0BHXUn4018269
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 17:33:30 GMT
Received: from [9.101.17.27] (mai.toulouse-stg.fr.ibm.com [9.101.17.27])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id m0BHXSFt018207
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 17:33:29 GMT
In-Reply-To: <20080111172641.GA22449@piper.oerlikon.madduck.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

martin f krafft wrote:
> also sprach Daniel Lezcano <dlezcano@fr.ibm.com> [2008.01.11.1813 +0100]:
>> There is a tweak in /proc/sys which activate secondaries promotion when a 
>> primary is deleted.
>>
>> /proc/sys/net/ipv4/conf/all/promote_secondaries
>>
>> I think it changes the behavior to the one you wish.
> 
> Totally. That would have been the last place I had looked.
> Thank you!
> 
> Do you have any idea why this isn't on by default?

This tweak is "recent" (2.6.16 as far as I remember), so I suppose the 
reason is to not puzzled people with a changed default behavior.

