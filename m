From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the
 wireless-drivers-next tree
Date: Thu, 15 Jun 2017 12:08:08 -0400 (EDT)
Message-ID: <20170615.120808.1402317729827497353.davem@davemloft.net>
References: <20170608122759.7ffda0c3@canb.auug.org.au>
        <20170613120024.2a1ce31b@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvalo@codeaurora.org,
        linux-wireless@vger.kernel.org, linux-next@vger.kernel.org,
        linux-kernel@vger.kernel.org, igor.mitsyanko.os@quantenna.com,
        dlebed@quantenna.com, smaksimenko@quantenna.com,
        smatyukevich@quantenna.com, btherthala@quantenna.com,
        hwang@quantenna.com, krath@quantenna.com, avinashp@quantenna.com
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170613120024.2a1ce31b@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 13 Jun 2017 12:00:24 +1000

> Hi Dave,
> 
> On Thu, 8 Jun 2017 12:27:59 +1000 Stephen Rothwell <sfr@canb.auug.org.au> wrote:
>>
>> After merging the wireless-drivers-next tree, today's linux-next build
>> (x86_64 allmodconfig) failed like this:
>> 
>> drivers/net/wireless/quantenna/qtnfmac/core.c: In function 'qtnf_core_net_attach':
>> drivers/net/wireless/quantenna/qtnfmac/core.c:319:5: error: 'struct net_device' has no member named 'destructor'
>>   dev->destructor = free_netdev;
>>      ^
>> 
>> Caused by commit
>> 
>>   98f44cb0655c ("qtnfmac: introduce new FullMAC driver for Quantenna chipsets")
> 
> This commit is now in the net-next tree ...
> 
>> interacting with commit
>> 
>>   cf124db566e6 ("net: Fix inconsistent teardown and release of private netdev state.")
>> 
>> from the net tree.
>> 
>> I applied this merge fix patch for today.
> 
> So this merge fix patch is needed when the net and net-next trees are merged.

This is now all resolved, thanks!
