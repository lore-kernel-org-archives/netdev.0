From: Vishwanath Pai <vpai@akamai.com>
Subject: Re: [PATCH net-next v3] netfilter: xt_hashlimit: Fix link error in
 32bit arch because of 64bit division
Date: Fri, 30 Sep 2016 13:58:03 -0400
Message-ID: <57EEA7AB.3010301@akamai.com>
References: <20160929173950.GA27689@akamai.com> <20160930174650.GE1176@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: johunt@akamai.com, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org,
        pai.vishwain@gmail.com, kaber@trash.net, kadlec@blackhole.kfki.hu,
        zlpnobody@gmail.com, hannes@stressinduktion.org, maze@google.com,
        eric.dumazet@gmail.com, akpm@linux-foundation.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay07.akamai.com ([23.79.238.175]:41051 "EHLO
        prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932430AbcI3R6E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 13:58:04 -0400
In-Reply-To: <20160930174650.GE1176@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/30/2016 01:46 PM, Pablo Neira Ayuso wrote:
> On Thu, Sep 29, 2016 at 01:39:50PM -0400, Vishwanath Pai wrote:
>> v2:
>> Remove unnecessary div64_u64 around constants
>>
>> v3:
>> remove backslashes
>>
>> --
>>
>> Fix link error in 32bit arch because of 64bit division
>>
>> Division of 64bit integers will cause linker error undefined reference
>> to `__udivdi3'. Fix this by replacing divisions with div64_64
> 
> Applied, thanks Pai.
> 
>> Signed-off-by: Vishwanath Pai <vpai@akamai.com>
>> Fixes: 11d5f15723c9 ("netfilter: xt_hashlimit: Create revision 2 to ...")
>>
>> ---
> 
> Please, next time place the versioning information here, otherwise git
> am takes the wrong description here.
> 

Thank you. And sorry about, I did not realize git am would put that into
the description.

-Vishwanath
