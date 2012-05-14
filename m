From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next 2/2] stmmac: add mixed burst for DMA
Date: Mon, 14 May 2012 09:22:20 +0200
Message-ID: <4FB0B2AC.5070903@st.com>
References: <1336381953-18041-1-git-send-email-peppe.cavallaro@st.com> <1336381953-18041-2-git-send-email-peppe.cavallaro@st.com> <20120511.181259.845221725995971870.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:43823 "EHLO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754391Ab2ENHXF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 03:23:05 -0400
In-Reply-To: <20120511.181259.845221725995971870.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/12/2012 12:12 AM, David Miller wrote:
> From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
> Date: Mon,  7 May 2012 11:12:33 +0200
> 
>> -	int (*init) (void __iomem *ioaddr, int pbl, int fb, int burst_len,
>> -			u32 dma_tx, u32 dma_rx);
>> +	int (*init) (void __iomem *ioaddr, int pbl, int fb, int mb,
>> +			int burst_len, u32 dma_tx, u32 dma_rx);
> 
> Fix the indentation of the arguments on the second line,
> the first character must line up with the first column after
> the function's openning parenthesis on the previous line.

Yes, my fault and fixed at once.

> 
>> -static int dwmac1000_dma_init(void __iomem *ioaddr, int pbl, int fb,
>> +static int dwmac1000_dma_init(void __iomem *ioaddr, int pbl, int fb, int mb,
>>  			      int burst_len, u32 dma_tx, u32 dma_rx)
> 
> While you're here fix up that issue in the existing code here as well.
> 
>> -static int dwmac100_dma_init(void __iomem *ioaddr, int pbl, int fb,
>> +static int dwmac100_dma_init(void __iomem *ioaddr, int pbl, int fb, int mb,
>>  			     int burst_len, u32 dma_tx, u32 dma_rx)
> 
> Likewise.

After applying the patch the argument "int burst_len" is aligned with
the first column after the opening parenthesis.
Anyway I've just re-looked at the code and verified that.

> 
>> -	int pbl = DEFAULT_DMA_PBL, fixed_burst = 0, burst_len = 0;
>> +	int pbl = DEFAULT_DMA_PBL, fixed_burst = 0, burst_len = 0,
>> +	    mixed_burst = 0;
> 
> This is gross, just make a new "int" declaration for mixed_burst.

fixed :-(

I'm resending the patches now.

Thanks for your review and sorry for these kind of errors.

peppe

> 
> 
> 
