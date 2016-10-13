From: Jonathan Cooper <jcooper@solarflare.com>
Subject: Re: [PATCH net] Revert "net: Add driver helper functions to determine
 checksum offloadability"
Date: Thu, 13 Oct 2016 16:31:41 +0100
Message-ID: <7e5fd685-1ff8-c030-ac44-eaed040b5cea@solarflare.com>
References: <20161011130409.7e6b54ff@xeon-e3>
 <20161013.103548.511298911926565246.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <tom@herbertland.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:41079 "EHLO
        nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754416AbcJMPh0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 11:37:26 -0400
In-Reply-To: <20161013.103548.511298911926565246.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/10/16 15:35, David Miller wrote:
> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Tue, 11 Oct 2016 13:04:09 -0700
>
>> This reverts commit 6ae23ad36253a8033c5714c52b691b84456487c5.
>>
>> The code has been in kernel since 4.4 but there are no in tree
>> code that uses. Unused code is broken code, remove it.
>>
>> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> Tom if you have any real plans to develop on this work at all in
> the immediate future, please speak up now.
>
> Otherwise I'm applying Stephen's patch.
>
> Thanks.

Oops, nope, I tell a lie. We used it initially and then realised we 
didn't strictly
need it since we only advertise IP_CSUM and IPV6_CSUM of inner
packets, so we should never be presented with a packet we'd need to
call the helper for. So we're not using it after all.

Jon
