From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: getsockopt(TCP_DEFER_ACCEPT) value change
Date: Tue, 05 Jan 2010 17:57:19 +0100
Message-ID: <4B436F6F.3090901@free.fr>
References: <4B4317AD.1040302@free.fr> <alpine.DEB.2.00.1001051526520.7024@wel-95.cs.helsinki.fi> <4B4348A7.4090509@gmail.com> <4B435EB5.1010902@free.fr> <4B43655F.5030807@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Julian Anastasov <ja@ssi.bg>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([194.196.100.166]:35322 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753978Ab0AEQ5X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 11:57:23 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate6.uk.ibm.com (8.13.1/8.13.1) with ESMTP id o05GvL0u020075
	for <netdev@vger.kernel.org>; Tue, 5 Jan 2010 16:57:21 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o05GvLl9634954
	for <netdev@vger.kernel.org>; Tue, 5 Jan 2010 16:57:21 GMT
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o05GvKgR018931
	for <netdev@vger.kernel.org>; Tue, 5 Jan 2010 16:57:21 GMT
In-Reply-To: <4B43655F.5030807@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le 05/01/2010 16:45, Daniel Lezcano a =E9crit :
>  =20
>  =20
>> It's not problem if the set / get values are not same, but I was ask=
ing
>> because I am working with a test suite checking if a checkpoint /
>> restart solution is correct.  One of these tests, sets the
>> TCP_DEFER_ACCEPT value to 12, checkpoints / restarts, and reads the
>> value in order to check if it was correctly restored. The value 12 w=
as
>> chosen because it is not rounded, so we were able to safely do the t=
est.
>> But with the 2.6.32, the behaviour changed, so I preferred to report=
 it
>> in case that is something not expected.
>>
>>
>>    =20
>
> 12 happened to be rounded to 12 with previous kernels,
> but with recent kernels we have another conversion table :
>  =20

Thanks Eric, I will change the test program.

  -- Daniel
