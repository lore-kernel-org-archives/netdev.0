From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net-next.git) 01/18] stmmac: share reset function
 between dwmac100 and dwmac1000
Date: Tue, 05 Jan 2016 13:45:09 -0500 (EST)
Message-ID: <20160105.134509.1955558752031082605.davem@davemloft.net>
References: <1451912823-5245-2-git-send-email-peppe.cavallaro@st.com>
	<20160104.222549.839329360046336198.davem@davemloft.net>
	<568B86E0.6000400@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexandre.torgue@st.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56923 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751703AbcAESpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 13:45:21 -0500
In-Reply-To: <568B86E0.6000400@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Tue, 5 Jan 2016 10:03:28 +0100

> On 1/5/2016 4:25 AM, David Miller wrote:
>> From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
>> Date: Mon, 4 Jan 2016 14:06:46 +0100
>>
>>> @@ -376,7 +376,8 @@ extern const struct stmmac_desc_ops ndesc_ops;
>>>   /* Specific DMA helpers */
>>>   struct stmmac_dma_ops {
>>>   	/* DMA core initialization */
>>> -	int (*init) (void __iomem *ioaddr, int pbl, int fb, int mb,
>>> +	int (*reset)(void __iomem *ioaddr);
>>> +	void (*init)(void __iomem *ioaddr, int pbl, int fb, int mb,
>>>   		     int burst_len, u32 dma_tx, u32 dma_rx, int atds);
>>
>> Since you change the return type of the 'init' method, and this
>> changes the column of the openning parenthesis, you have to fix the
>> indentation of the argument list on the next line.
>>
> 
> hmm, lines are well aligned.
> 
> I will check again, in case of I introduced some indentation problem.

Either it was wrong to begin with (I checked before I replied to this posting
and didn't see a misalignment) or it is wrong after the change since void is
one more column more than int.
