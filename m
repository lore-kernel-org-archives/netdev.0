From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [RFC] network namespaces
Date: Wed, 06 Sep 2006 11:10:23 +0200
Message-ID: <44FE907F.7090508@fr.ibm.com>
References: <20060815182029.A1685@castle.nmd.msu.ru> <20060816115313.GC31810@sergelap.austin.ibm.com> <44FD7CF0.4030009@fr.ibm.com> <m1ejuq2wz0.fsf@ebiederm.dsl.xmission.com> <20060905165328.GA17317@MAIL.13thfloor.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org, "Serge E. Hallyn" <serue@us.ibm.com>,
	Andrey Savochkin <saw@sw.ru>, haveblue@us.ibm.com,
	clg@fr.ibm.com, sam@vilain.net, Andrew Morton <akpm@osdl.org>,
	dev@sw.ru, devel@openvz.org, alexey@sw.ru,
	Linux Containers <containers@lists.osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([195.212.29.135]:50726 "EHLO
	mtagate2.uk.ibm.com") by vger.kernel.org with ESMTP
	id S1750721AbWIFJK1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Sep 2006 05:10:27 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate2.uk.ibm.com (8.13.7/8.13.7) with ESMTP id k869APfN085550
	for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 09:10:25 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k869CVBe1499140
	for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 10:12:31 +0100
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k869ANHP002889
	for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 10:10:24 +0100
To: Herbert Poetzl <herbert@13thfloor.at>
In-Reply-To: <20060905165328.GA17317@MAIL.13thfloor.at>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Herbert,

> well, the 'ip subset' approach Linux-VServer and
> other Jail solutions use is very clean, it just does
> not match your expectations of a virtual interface
> (as there is none) and it does not cope well with
> all kinds of per context 'requirements', which IMHO
> do not really exist on the application layer (only
> on the whole system layer)
> 
> IMHO that would be quite simple, have a 'namespace'
> for limiting port binds to a subset of the available
> ips and another one which does complete network 
> virtualization with all the whistles and bells, IMHO
> most of them are orthogonal and can easily be combined
> 
>  - full network virtualization
>  - lightweight ip subset 
>  - both
> 
> IMHO this requirement only arises from the full system
> virtualization approach, just look at the other jail
> solutions (solaris, bsd, ...) some of them do not even 
> allow for more than a single ip but they work quite
> well when used properly ...

As far as I see, vserver use a layer 3 solution but, when needed, the 
veth "component", made by Nestor Pena, is used to provide a layer 2 
virtualization. Right ?

Having the two solutions, you have certainly a lot if information about 
use cases. From the point of view of vserver, can you give some examples 
of when a layer 3 solution is better/worst than a layer 2 solution ? Who 
wants a layer 2/3 virtualization and why ?

These informations will be very useful.

Regards

   -- Daniel
