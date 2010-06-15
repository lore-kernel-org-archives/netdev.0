From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2/8] user_ns: Introduce user_nsmap_uid and user_ns_map_gid.
Date: Tue, 15 Jun 2010 15:37:51 -0700
Message-ID: <m1typ3udkw.fsf@fess.ebiederm.org>
References: <m1hbl7hxo3.fsf@fess.ebiederm.org>
	<m1d3vvhxlj.fsf@fess.ebiederm.org>
	<m17hm3hxjw.fsf_-_@fess.ebiederm.org> <4C173389.1010000@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Serge Hallyn <serue@us.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	Daniel Lezcano <daniel.lezcano@free.fr>, netdev@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:43164 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754609Ab0FOWiA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 18:38:00 -0400
In-Reply-To: <4C173389.1010000@openvz.org> (Pavel Emelyanov's message of "Tue\, 15 Jun 2010 12\:02\:17 +0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov <xemul@openvz.org> writes:

> On 06/13/2010 05:28 PM, Eric W. Biederman wrote:
>> 
>> Define what happens when a we view a uid from one user_namespace
>> in another user_namepece.
>> 
>> - If the user namespaces are the same no mapping is necessary.
>> 
>> - For most cases of difference use overflowuid and overflowgid,
>>   the uid and gid currently used for 16bit apis when we have a 32bit uid
>>   that does fit in 16bits.  Effectively the situation is the same,
>>   we want to return a uid or gid that is not assigned to any user.
>> 
>> - For the case when we happen to be mapping the uid or gid of the
>>   creator of the target user namespace use uid 0 and gid as confusing
>>   that user with root is not a problem.
>> 
>> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
>
> I suppose this one should go via Andrew, not Dave.

If it was stand alone I would send it that way.

In this case I'm hope Dave will indulge me because this bit is
simple, the only user for now is the network stack, and the people
maintaining the code have already acked the patch.

Eric
