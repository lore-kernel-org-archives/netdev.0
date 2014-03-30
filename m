From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] packet: respect devices with LLTX flag in direct
 xmit
Date: Sun, 30 Mar 2014 23:52:04 +0200
Message-ID: <53389204.2010205@redhat.com>
References: <1395934710-29182-1-git-send-email-dborkman@redhat.com>  <20140328.165058.1610297081920676758.davem@davemloft.net>  <5335E604.4020105@redhat.com> <1396105350.21428.6.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25668 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751897AbaC3VwJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Mar 2014 17:52:09 -0400
In-Reply-To: <1396105350.21428.6.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/29/2014 04:02 PM, Eric Dumazet wrote:
> On Fri, 2014-03-28 at 22:13 +0100, Daniel Borkmann wrote:
>> On 03/28/2014 09:50 PM, David Miller wrote:
>
>>> The only remaining issue is that Eric seems to suggest that a tx
>>> dropped counter bump should be added.  Please submit that as a
>>> follow-on if my reading of his feedback is accurate.
>>
>> Yes, will do next week. I think at time of submission we didn't
>> have that yet. :)
>
> BTW, how direct xmit performs in case of BQL enabled driver ?
>
> dummy is nice, but not really representative of real device ;)
>
> netif_xmit_frozen_or_stopped() tests (dev_queue->state &
> QUEUE_STATE_ANY_XOFF_OR_FROZEN), so will not fill TX ring.
>
> Since you have no queue, I would rather use a test without
> BQL bit (1 << __QUEUE_STATE_STACK_XOFF), so that you can absorb bursts
> into TX ring ...

Thanks Eric, I'll look into it on next Tuesday [I was on travel
whole weekend and will be on Monday].
