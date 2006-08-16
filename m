From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 3/9] network namespaces: playing and debugging
Date: Wed, 16 Aug 2006 11:22:28 -0600
Message-ID: <m164gs38a3.fsf@ebiederm.dsl.xmission.com>
References: <20060815182029.A1685@castle.nmd.msu.ru>
	<20060815184843.A2882@castle.nmd.msu.ru>
	<20060816094641.61190ee9@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrey Savochkin <saw@sw.ru>, netdev@vger.kernel.org,
	dlezcano@fr.ibm.com, serue@us.ibm.com, haveblue@us.ibm.com,
	clg@fr.ibm.com, herbert@13thfloor.at, sam@vilain.net,
	ebiederm@xmission.com, Andrew Morton <akpm@osdl.org>, dev@sw.ru,
	devel@openvz.org, alexey@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:44944 "EHLO
	ebiederm.dsl.xmission.com") by vger.kernel.org with ESMTP
	id S1751218AbWHPRXw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 13:23:52 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060816094641.61190ee9@localhost.localdomain> (Stephen
	Hemminger's message of "Wed, 16 Aug 2006 09:46:41 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> writes:

> On Tue, 15 Aug 2006 18:48:43 +0400
> Andrey Savochkin <saw@sw.ru> wrote:
>
>> Temporary code to play with network namespaces in the simplest way.
>> Do
>>         exec 7< /proc/net/net_ns
>> in your bash shell and you'll get a brand new network namespace.
>> There you can, for example, do
>>         ip link set lo up
>>         ip addr list
>>         ip addr add 1.2.3.4 dev lo
>>         ping -n 1.2.3.4
>> 
>> Signed-off-by: Andrey Savochkin <saw@swsoft.com>
>
> NACK, new /proc interfaces are not acceptable.

The rule is that new /proc interfaces that are not process related
are not acceptable.  If structured right a network namespace can
arguably be process related.

I do agree that this interface is pretty ugly there.

Eric
