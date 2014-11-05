From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net v3] ipv6: mld: fix add_grhead skb_over_panic for devs
 with large MTUs
Date: Wed, 05 Nov 2014 17:26:42 +0100
Message-ID: <545A4FC2.4010109@redhat.com>
References: <1415198530-7126-1-git-send-email-dborkman@redhat.com> <1415204413.13896.5.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, lw1a2.jing@gmail.com, fw@strlen.de,
	hannes@stressinduktion.org, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	David L Stevens <david.stevens@oracle.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41504 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754811AbaKEQ1D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2014 11:27:03 -0500
In-Reply-To: <1415204413.13896.5.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/05/2014 05:20 PM, Eric Dumazet wrote:
> On Wed, 2014-11-05 at 15:42 +0100, Daniel Borkmann wrote:
>> It has been reported that generating an MLD listener report on
>> devices with large MTUs (e.g. 9000) and a high number of IPv6
>> addresses can trigger a skb_over_panic():
> ...
>>   v2->v3:
>>    - Still had a discussion w/ Hannes and improved the code a bit to
>>      make it more clear to read
>
> I am very sorry Daniel, but I found v2 much easier to understand :(
>
> Could you refrain from doing cleanups in this patch,
> only provide the very minimal fix ?
>
> No empty lines additions or deletions and stuff like that...
>
> Then, we can cleanup for net-next later if you really want ;)
>
> I know its _very_ tempting to do cleanups, but its very time consuming
> to review patches having real stuff done (like bug fixes) and cleanups.

I can understand, sorry, I'm fine with either version actually.

Thanks,
Daniel
