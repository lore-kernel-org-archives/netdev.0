From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [iproute PATCH 0/2] Netns performance improvements
Date: Fri, 8 Jul 2016 10:18:47 -0700
Message-ID: <577FE077.2010203@hpe.com>
References: <1467729773-16751-1-git-send-email-phil@nwl.cc>
 <87twg4ywjz.fsf@x220.int.ebiederm.org> <20160705205103.GE620@orbyte.nwl.cc>
 <87h9c259ip.fsf@x220.int.ebiederm.org> <20160707111718.GL620@orbyte.nwl.cc>
 <577E5244.8030601@6wind.com> <20160707154809.GN620@orbyte.nwl.cc>
 <577E8054.6040603@hpe.com> <577F5DC9.7020303@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: nicolas.dichtel@6wind.com, Phil Sutter <phil@nwl.cc>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Stephen Hemminger <shemming@brocade.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3427.houston.hpe.com ([15.241.140.73]:58409 "EHLO
	g4t3427.houston.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932118AbcGHRSu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 13:18:50 -0400
In-Reply-To: <577F5DC9.7020303@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/08/2016 01:01 AM, Nicolas Dichtel wrote:
>> Those 300 routers will each have at least one namespace along with the dhcp
>> namespaces.  Depending on the nature of the routers (Distributed versus
>> Centralized Virtual Routers - DVR vs CVR) and whether the routers are supposed
>> to be "HA" there can be more than one namespace for a given router.
>>
>> 300 routers is far from the upper limit/goal.  Back in HP Public Cloud, we were
>> running as many as 700 routers per network node (*), and more than four network
>> nodes. (back then it was just the one namespace per router and network). Mileage
>> will of course vary based on the "oomph" of one's network node(s).
> Thank you for the details.
>
> Do you have a script or something else to easily reproduce this problem?

Do you mean for my much older, slightly different stuff done in HP 
Public Cloud, or for what Phil (?) is doing presently?  I believe Phil 
posted something several messages back in the thread.

happy benchmarking,

rick jones
