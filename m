From: Josh Hunt <johunt@akamai.com>
Subject: Re: [PATCH] net: udp: add socket option to report RX queue level
Date: Fri, 17 Mar 2017 23:01:19 -0500
Message-ID: <eb65772f-8bb3-944b-d213-263008028bb3@akamai.com>
References: <20170317211312.38117-1-ckuiper@google.com>
 <1489788070.28631.322.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pgynther@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>,
        Chris Kuiper <ckuiper@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay05.akamai.com ([23.79.238.179]:58632 "EHLO
        prod-mail-xrelay05.akamai.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750957AbdCREBW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Mar 2017 00:01:22 -0400
In-Reply-To: <1489788070.28631.322.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/17/2017 05:01 PM, Eric Dumazet wrote:
> On Fri, 2017-03-17 at 14:13 -0700, Chris Kuiper wrote:
>> This adds a new socket option "SO_RXQ_ALLOC" that enables providing
>> the RX queue buffer allocation as ancillary data from the recvmsg()
>> system call. The value reported is a byte number and together with
>> the RX queue size (obtained via getsockopt(SO_RCVBUF) can be used to
>> calculate a percentage value on how full the socket buffer is.
>> ---
>
> Seems a lot of overhead, and only UDP would be supported.
>
> I very much prefer Josh Hunt proposal
> ( https://patchwork.ozlabs.org/patch/738250/ )
>
> Ie using a separate getsockopt() call instead of adding code to UDP fast
> path ?
>

Yes, let me know and I can send a patch adding a sockopt to return all 
of the meminfo vars.
