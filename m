From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH (net-next.git) 09/18] stmmac: optimize tx desc management
Date: Tue, 5 Jan 2016 09:57:24 +0100
Message-ID: <568B8574.7070304@st.com>
References: <1451912823-5245-1-git-send-email-peppe.cavallaro@st.com>	<1451912823-5245-10-git-send-email-peppe.cavallaro@st.com> <20160104.223916.1424025684080316788.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <alexandre.torgue@st.com>,
	<fabrice.gasnier@st.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:4894 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750972AbcAEI5a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 03:57:30 -0500
In-Reply-To: <20160104.223916.1424025684080316788.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/5/2016 4:39 AM, David Miller wrote:
> From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Date: Mon, 4 Jan 2016 14:06:54 +0100
>
>> @@ -334,12 +334,11 @@ struct stmmac_desc_ops {
>>
>>   	/* Invoked by the xmit function to prepare the tx descriptor */
>>   	void (*prepare_tx_desc) (struct dma_desc *p, int is_fs, int len,
>> -				 int csum_flag, int mode);
>> +				 int csum_flag, int mode, int tx_own,
>> +				 bool ls_ic);
>
> I don't understand how you can get the type right and use 'bool' for
> 'ls_ic' but then incorrectly use an int for 'tx_own'.
>

sure I will fix it too.

thanks
