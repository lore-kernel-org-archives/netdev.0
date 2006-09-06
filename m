From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [Devel] Re: [RFC] network namespaces
Date: Wed, 06 Sep 2006 23:44:35 +0200
Message-ID: <44FF4143.9050708@fr.ibm.com>
References: <20060815182029.A1685@castle.nmd.msu.ru>	<20060816115313.GC31810@sergelap.austin.ibm.com>	<44FD7CF0.4030009@fr.ibm.com>	<m1ejuq2wz0.fsf@ebiederm.dsl.xmission.com>	<20060905165328.GA17317@MAIL.13thfloor.at>	<44FE907F.7090508@fr.ibm.com> <20060906165642.GA26202@MAIL.13thfloor.at> <44FF0760.1040600@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
Cc: devel@openvz.org, Andrew Morton <akpm@osdl.org>,
	netdev@vger.kernel.org, sam@vilain.net,
	Andrey Savochkin <saw@sw.ru>, alexey@sw.ru,
	Linux Containers <containers@lists.osdl.org>,
	"Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:20802 "EHLO
	mtagate5.de.ibm.com") by vger.kernel.org with ESMTP
	id S1751691AbWIFVon (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Sep 2006 17:44:43 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.8/8.13.8) with ESMTP id k86LierT119314
	for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 21:44:41 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k86Ln6NK3121208
	for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 23:49:06 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k86LiewF031358
	for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 23:44:40 +0200
To: Kir Kolyshkin <kir@openvz.org>
In-Reply-To: <44FF0760.1040600@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kir Kolyshkin wrote:
> Herbert Poetzl wrote:
> 
>> my point (until we have an implementation which clearly
>> shows that performance is equal/better to isolation)
>> is simply this:
>>
>>  of course, you can 'simulate' or 'construct' all the
>>  isolation scenarios with kernel bridging and routing
>>  and tricky injection/marking of packets, but, this
>>  usually comes with an overhead ...
>>   
> 
> Well, TANSTAAFL*, and pretty much everything comes with an overhead. 
> Multitasking comes with the (scheduler, context switch, CPU cache, etc.) 
> overhead -- is that the reason to abandon it? OpenVZ and Linux-VServer 
> resource management also adds some overhead -- do we want to throw it away?
> 
> The question is not just "equal or better performance", the question is 
> "what do we get and how much we pay for it".
> 
> Finally, as I understand both network isolation and network 
> virtualization (both level2 and level3) can happily co-exist. We do have 
> several filesystems in kernel. Let's have several network virtualization 
> approaches, and let a user choose. Is that makes sense?

Definitly yes, I agree.
