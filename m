From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH (net-next.git) 16/18] stmmac: do not perform zero-copy
 for rx frames
Date: Wed, 16 Dec 2015 12:33:28 +0100
Message-ID: <56714C08.7040701@st.com>
References: <1449650274-14896-1-git-send-email-peppe.cavallaro@st.com>	<1449650274-14896-17-git-send-email-peppe.cavallaro@st.com> <20151211.200929.1933211408365625907.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <alexandre.torgue@st.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:27910 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750788AbbLPLds (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 06:33:48 -0500
In-Reply-To: <20151211.200929.1933211408365625907.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/12/2015 2:09 AM, David Miller wrote:
> From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Date: Wed, 9 Dec 2015 09:37:52 +0100
>
>> @@ -98,6 +98,10 @@ static int buf_sz = DEFAULT_BUFSIZE;
>>   module_param(buf_sz, int, S_IRUGO | S_IWUSR);
>>   MODULE_PARM_DESC(buf_sz, "DMA buffer size");
>>
>> +static int minrx = 256;
>> +module_param(minrx, int, S_IRUGO | S_IWUSR);
>> +MODULE_PARM_DESC(minrx, "Copy only tiny-frames");
>> +
>
> When you type module_param() in a network driver, you ought to receive
> an electric shock in order to remind you that except in the most extreme
> cases module parameters are absolutely not appropriate.
>
> In this case we have an ethtool tunable people can use to control copy
> break values like this, so use that instead.

ok, v2 will have this change. Let me know if there is other to fix.

Peppe
