From: Roman Yeryomin <roman@advem.lv>
Subject: Re: [PATCH net-next 00/10] korina cleanups/optimizations
Date: Sun, 15 Oct 2017 19:46:02 +0300
Message-ID: <c3a2f516dcceb7dee9ea4dde634b58ed@advem.lv>
References: <20171015162226.606-1-roman@advem.lv>
 <0FA80CB3-C0DC-4B30-B638-26B5D46AE69E@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>,
        netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1l1v.rtu.lv ([213.175.92.62]:52687 "EHLO mail.pbx.lv"
        rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
        id S1751258AbdJOQqE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 15 Oct 2017 12:46:04 -0400
In-Reply-To: <0FA80CB3-C0DC-4B30-B638-26B5D46AE69E@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-10-15 19:38, Florian Fainelli wrote:
> On October 15, 2017 9:22:26 AM PDT, Roman Yeryomin <roman@advem.lv> 
> wrote:
>> TX optimizations have led to ~15% performance increase (35->40Mbps)
>> in local tx usecase (tested with iperf v3.2).
> 
> Could you avoid empty commit messages and write a paragraph or two for
> each commit that explains what and why are you changing? The changes
> look fine but they lack any explanation.

I thought that short descriptions are already self explanatory and just 
didn't know what to write more.
To me they are very obvious.
Do you really want me to make up something more?

>> 
>> Roman Yeryomin (10):
>>  net: korina: optimize korina_send_packet logic
>>  net: korina: reorder functions
>>  net: korina: introduce and use interrupt disable/enable helpers
>>  net: korina: optimize tx/rx interrupt handlers
>>  net: korina: remove unused korina_private members
>>  net: korina: optimize tx descriptor flags processing
>>  net: korina: move tx to napi context
>>  net: korina: optimize tx_full condition
>>  net: korina: use dma api instead of dma_cache_* functions
>>  net: korina: bump version
>> 
>> drivers/net/ethernet/korina.c | 503
>> +++++++++++++++++-------------------------
>> 1 file changed, 204 insertions(+), 299 deletions(-)
