From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH net-next] [RFC] netns: enable cross-ve Unix sockets
Date: Wed, 01 Oct 2008 17:38:53 +0200
Message-ID: <48E3998D.4040709@fr.ibm.com>
References: <1222858454-7843-1-git-send-email-den@openvz.org> <48E35B4C.1040303@fr.ibm.com> <1222860776.23573.49.camel@iris.sw.ru> <48E3653C.1070701@fr.ibm.com> <1222862583.23573.54.camel@iris.sw.ru> <48E36ABF.8030908@fr.ibm.com> <48E36BFA.3040904@openvz.org> <48E36DA0.9080400@fr.ibm.com> <1222866717.23573.58.camel@iris.sw.ru> <48E37F1B.20601@fr.ibm.com> <1222872885.23573.64.camel@iris.sw.ru> <48E394D2.5090709@fr.ibm.com> <48E397C1.6050407@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Denis V. Lunev" <den@openvz.org>, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org, benjamin.thery@bull.net,
	ebiederm@xmission.com
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.17.162]:41314 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752720AbYJAPjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 11:39:00 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.1/8.13.1) with ESMTP id m91Fcx4X004388
	for <netdev@vger.kernel.org>; Wed, 1 Oct 2008 15:38:59 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m91FcwLJ2519274
	for <netdev@vger.kernel.org>; Wed, 1 Oct 2008 17:38:58 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m91Fctkx007498
	for <netdev@vger.kernel.org>; Wed, 1 Oct 2008 17:38:55 +0200
In-Reply-To: <48E397C1.6050407@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
>> Yes per namespace, I agree.
>>
>> If the option is controlled by the parent and it is done by sysctl, you 
>> will have to make proc/sys per namespace like Pavel did with /proc/net, no ?
> 
> /proc/sys is already per namespace actually ;) Or what did you mean by that?


Effectively I was not clear :)

I meant, you can not access /proc/sys from outside the namespace like 
/proc/net which can be followed up by /proc/<pid>/net outside the namespace.
