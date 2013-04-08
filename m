From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [Patch net-next] tcp: add a global sysctl to control TCP delayed
 ack
Date: Mon, 08 Apr 2013 09:39:31 -0700
Message-ID: <5162F2C3.10107@hp.com>
References: <1365070560-11544-1-git-send-email-amwang@redhat.com> <20130407.170958.338519719729552895.davem@davemloft.net> <1365385541.31063.0.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, shemminger@vyatta.com, tgraf@suug.ch,
	David.Laight@ACULAB.COM
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:14261 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934393Ab3DHQjf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 12:39:35 -0400
In-Reply-To: <1365385541.31063.0.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/07/2013 06:45 PM, Cong Wang wrote:
> On Sun, 2013-04-07 at 17:09 -0400, David Miller wrote:
>>
>> I'm not applying a patch that adds a global parameter for
>> an attribute which has per-path scope.
>
> Ok, I will make it per-route.

Is setting a per-route attribute to cover the backside of an application 
for which source code is not available in this day and age really all 
that much easier than hitting that application with an LD_PRELOAD 
library to make the desired setsockopt() call?

rick jones
having flashbacks to similar conversations in other contexts in the 1990s...
