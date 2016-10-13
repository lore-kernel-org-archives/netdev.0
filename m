From: Jonathan Cooper <jcooper@solarflare.com>
Subject: Re: [PATCH net] Revert "net: Add driver helper functions to determine
 checksum offloadability"
Date: Thu, 13 Oct 2016 16:06:17 +0100
Message-ID: <dd10f71e-4104-369b-8350-eb150d3efaea@solarflare.com>
References: <20161011130409.7e6b54ff@xeon-e3>
 <20161013.103548.511298911926565246.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <tom@herbertland.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:23658 "EHLO
        nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756083AbcJMPRr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 11:17:47 -0400
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

We've used this in our overlay support, which we plan to upstream in the 
next month or two (or at least Soon(tm)),
so we'd rather it stayed in otherwise we'll just have to reimplement it.

Jon
