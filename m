From: Alex <alex.g@adaptrum.com>
Subject: Re: [PATCH 3/5] net: stmmac: Add Adaptrum Anarion GMAC glue layer
Date: Mon, 31 Jul 2017 08:11:00 -0700
Message-ID: <b3a51afc-1eae-66ea-f20e-a09cd8289c1b@adaptrum.com>
References: <20170728220707.13960-1-alex.g@adaptrum.com>
 <20170728220707.13960-4-alex.g@adaptrum.com>
 <20170728.190155.457209566729295513.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org,
        robh+dt@kernel.org, mark.rutland@arm.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170728.190155.457209566729295513.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On 07/28/2017 07:01 PM, David Miller wrote:
> From: Alexandru Gagniuc <alex.g@adaptrum.com>
> Date: Fri, 28 Jul 2017 15:07:03 -0700
>
>> Before the GMAC on the Anarion chip can be used, the PHY interface
>> selection must be configured with the DWMAC block in reset.
>>
>> This layer covers a block containing only two registers. Although it
>> is possible to model this as a reset controller and use the "resets"
>> property of stmmac, it's much more intuitive to include this in the
>> glue layer instead.
>>
>> At this time only RGMII is supported, because it is the only mode
>> which has been validated hardware-wise.
>>
>> Signed-off-by: Alexandru Gagniuc <alex.g@adaptrum.com>
>
> I don't see how this fits into any patch series at all.  If this is
> part of a series you posted elsewhere, you should keep netdev@ on
> all such postings so people there can review the change in-context.

I used the --cc-cmd option to send-email. I'll be sure to CC netdev@ on 
[PATCH v2].

Alex
