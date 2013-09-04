From: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
Subject: Re: [PATCH net-next 3/5] driver/net: enic: Try DMA 64 first, then
 failover to DMA
Date: Wed, 4 Sep 2013 11:31:38 +0530 (IST)
Message-ID: <alpine.LNX.2.03.1309041127380.1814@gmail.com>
References: <1378273638-7780-1-git-send-email-govindarajulu90@gmail.com> <1378273638-7780-4-git-send-email-govindarajulu90@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, benve@cisco.com, ssujith@cisco.com,
	nistrive@cisco.com, umalhi@cisco.com
To: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1378273638-7780-4-git-send-email-govindarajulu90@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave

The subject for this should be "driver/net: enic: Try DMA 64 first, then
failover to DMA 32"

The "32" got truncated, please add this while committing. Let me know if
you want me to send another patch.

thanks
//govind

On Wed, 4 Sep 2013, Govindarajulu Varadarajan wrote:

> In servers with more than 1.1 TB of RAM, the existing 40/32 bit DMA
> could cause failure as the DMA-able address could go outside the range
> addressable using 40/32 bits.
>
> The following patch first tried 64 bit DMA if possible, failover to 32
> bit.
>
> Signed-off-by: Sujith Sankar <ssujith@cisco.com>
> Signed-off-by: Christian Benvenuti <benve@cisco.com>
> Signed-off-by: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
