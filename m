From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: linux-next: build failure after merge of the final tree (net-next
 tree related)
Date: Fri, 06 Apr 2012 09:09:45 +0200
Message-ID: <4F7E96B9.9060907@st.com>
References: <20120405132515.e61465875407a452c1a6f78e@canb.auug.org.au> <20120404.235933.350585244341009071.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	deepak.sikri@st.com, shiraz.hashim@st.com, vikas.manocha@st.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20120404.235933.350585244341009071.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/5/2012 5:59 AM, David Miller wrote:
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Thu, 5 Apr 2012 13:25:15 +1000
> 
>> After merging the final tree, today's linux-next build (powerpc
>> allyesconfig) failed like this:
>>
>> drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c: In function 'stmmac_probe_config_dt':
>> drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c:53:7: error: 'struct plat_stmmacenet_data' has no member named 'pbl'
>>
>> Caused by commit 8327eb65e795 ("stmmac: re-work the internal GMAC DMA
>> platf parameters").  Clearly I am missing something, because I can't see
>> how that patch is correct since nothing ever assigns to the new dma_cfg
>> pointer but it is dereferenced.
>>
>> I have added this patch to make it build today, but it is obviously not
>> correct.
> 
> Sorry Stephen.
> 
> Giuseppe don't submit patches to me that don't even compile.
> 
> Please submit a proper fix to me for this _now_.

Sorry Dave!
I don't know what happened (I believed to test all).
I'm sending you the patches soon!!!

Peppe

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
