From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH (net-next.git) 01/18] stmmac: share reset function between
 dwmac100 and dwmac1000
Date: Tue, 5 Jan 2016 10:03:28 +0100
Message-ID: <568B86E0.6000400@st.com>
References: <1451912823-5245-1-git-send-email-peppe.cavallaro@st.com>	<1451912823-5245-2-git-send-email-peppe.cavallaro@st.com> <20160104.222549.839329360046336198.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <alexandre.torgue@st.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:38305 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751221AbcAEJDd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 04:03:33 -0500
In-Reply-To: <20160104.222549.839329360046336198.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/5/2016 4:25 AM, David Miller wrote:
> From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Date: Mon, 4 Jan 2016 14:06:46 +0100
>
>> @@ -376,7 +376,8 @@ extern const struct stmmac_desc_ops ndesc_ops;
>>   /* Specific DMA helpers */
>>   struct stmmac_dma_ops {
>>   	/* DMA core initialization */
>> -	int (*init) (void __iomem *ioaddr, int pbl, int fb, int mb,
>> +	int (*reset)(void __iomem *ioaddr);
>> +	void (*init)(void __iomem *ioaddr, int pbl, int fb, int mb,
>>   		     int burst_len, u32 dma_tx, u32 dma_rx, int atds);
>
> Since you change the return type of the 'init' method, and this
> changes the column of the openning parenthesis, you have to fix the
> indentation of the argument list on the next line.
>

hmm, lines are well aligned.

I will check again, in case of I introduced some indentation problem.

peppe
