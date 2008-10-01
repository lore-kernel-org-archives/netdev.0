From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH net-next] [RFC] netns: enable cross-ve Unix sockets
Date: Wed, 01 Oct 2008 14:31:28 +0200
Message-ID: <48E36DA0.9080400@fr.ibm.com>
References: <1222858454-7843-1-git-send-email-den@openvz.org> <48E35B4C.1040303@fr.ibm.com> <1222860776.23573.49.camel@iris.sw.ru> <48E3653C.1070701@fr.ibm.com> <1222862583.23573.54.camel@iris.sw.ru> <48E36ABF.8030908@fr.ibm.com> <48E36BFA.3040904@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	benjamin.thery@bull.net, ebiederm@xmission.com,
	Denis Lunev <den@openvz.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:47315 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754082AbYJAMbu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 08:31:50 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.8/8.13.8) with ESMTP id m91CVgah211542
	for <netdev@vger.kernel.org>; Wed, 1 Oct 2008 12:31:42 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m91CVgWw2699350
	for <netdev@vger.kernel.org>; Wed, 1 Oct 2008 14:31:42 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m91CVcK9010743
	for <netdev@vger.kernel.org>; Wed, 1 Oct 2008 14:31:39 +0200
In-Reply-To: <48E36BFA.3040904@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
>> So there are 2 cases:
>>   * full isolation : restriction on VPS
>>   * partial isolation : no restriction but *perhaps* problem when migrating
>>
>> Looks like we need an option per namespace to reduce the isolation for 
>> af_unix sockets :)
>>   - on (default): current behaviour => full isolation
>>   - off : partial isolation
> 
> You mean some sysctl, that enables/disables this check in unix_find_socket_byinode?

Yes.
