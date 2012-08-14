From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 03/19] netfilter: nf_nat_sip: fix via header translation
 with multiple parameters
Date: Tue, 14 Aug 2012 14:23:18 +0200 (MEST)
Message-ID: <Pine.GSO.4.63.1208141422240.24346@stinky-local.trash.net>
References: <1344542943-11588-1-git-send-email-kaber@trash.net>
 <1344542943-11588-4-git-send-email-kaber@trash.net> <20120814002857.GC14483@1984>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120814002857.GC14483@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 14 Aug 2012, Pablo Neira Ayuso wrote:

> On Thu, Aug 09, 2012 at 10:08:47PM +0200, kaber@trash.net wrote:
>> From: Patrick McHardy <kaber@trash.net>
>>
>> Via-headers are parsed beginning at the first character after the Via-address.
>> When the address is translated first and its length decreases, the offset to
>> start parsing at is incorrect and header parameters might be missed.
>>
>> Update the offset after translating the Via-address to fix this.
>
> Applied, thanks Patrick.

Thanks Pablo. I'll submit the final IPv6-NAT patches once these three
patches have made it into net-next/nf-next.

