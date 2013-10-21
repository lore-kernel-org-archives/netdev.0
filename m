From: Daniel Wagner <wagi@monom.org>
Subject: Re: [PATCH nf-next] netfilter: xtables: lightweight process control
 group matching
Date: Mon, 21 Oct 2013 16:09:22 +0100
Message-ID: <526543A2.2040901@monom.org>
References: <1380910855-12325-1-git-send-email-dborkman@redhat.com> <87li1qp3l8.fsf@xmission.com> <526231E0.6060903@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, Tejun Heo <tj@kernel.org>,
	cgroups@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hotel311.server4you.de ([85.25.146.15]:57296 "EHLO
	hotel311.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753166Ab3JUPPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 11:15:48 -0400
In-Reply-To: <526231E0.6060903@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel

On 10/19/2013 08:16 AM, Daniel Borkmann wrote:
> On 10/19/2013 01:21 AM, Eric W. Biederman wrote:
>
>> I am coming to this late.  But two concrete suggestions.
>>
>> 1) process groups and sessions don't change as frequently as pids.
>>
>> 2) It is possible to put a set of processes in their own network
>>     namespace and pipe just the packets you want those processes to
>>     use into that network namespace.  Using an ingress queueing filter
>>     makes that process very efficient even if you have to filter by port.
>
> Actually in our case we're filtering outgoing traffic, based on which
> local socket that originated from; so you wouldn't need all of that
> construct. Also, you wouldn't even need to have an a-prio knowledge of
> the application internals regarding their use of particular use of ports
> or protocols. I don't think that such a setup will have the same
> efficiency, ease of use, and power to distinguish the application the
> traffic came from in such a lightweight, protocol independent and easy way.

Sorry for beeing late as well (and also stupid question)

Couldn't you use something from the LSM? I mean you allow the
application to create the socket etc and then block later
the traffic originated from that socket. Wouldn't it make
more sense to block early?

cheers,
daniel
