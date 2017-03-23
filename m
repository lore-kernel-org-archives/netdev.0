From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: stmmac: Performance regression after commit aff3d9eff843 "net:
 stmmac: enable multiple buffers"
Date: Thu, 23 Mar 2017 10:56:55 +0000
Message-ID: <89948183-5dba-af4e-8fd1-2a6add6750c8@synopsys.com>
References: <20170323100828.GC16625@Red>
 <68200e05-04fd-1cc1-f6d6-f77e9e6f1d9d@synopsys.com>
 <20170323102037.GD16625@Red>
 <a7c928ec-e4e5-b618-d0d4-2a833be10d53@synopsys.com>
 <465dc72e-8a1f-b41f-105f-add2164df6d5@st.com>
 <5c305629-0b61-88e5-5c48-4616cd687d9f@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <alexandre.torgue@st.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>,
        <linux-arm-kernel@lists.infradead.org>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay2.synopsys.com ([198.182.60.111]:48538 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751313AbdCWK7I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 06:59:08 -0400
In-Reply-To: <5c305629-0b61-88e5-5c48-4616cd687d9f@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Às 10:51 AM de 3/23/2017, Giuseppe CAVALLARO escreveu:
> On 3/23/2017 11:48 AM, Giuseppe CAVALLARO wrote:
>> Hello
>>
>> On 3/23/2017 11:20 AM, Corentin Labbe wrote:
>>>> I have a 4.21 QoS Core with 4 RX + 4 TX and detected no regression.
>>>> >Could you please share the iperf cmds you are using in order for me to
>>>> reproduce
>>>> >in my side?
>>
>> Joao, you have a really powerful HW integration with multiple channels for
>> both RX and TX.
>> Often this is not the same for other setup where, usually just a DMA0 is
>> present or, sometime, there
>> is just one RX extra channel.
>>
>> My question is, what happens on this kind of configurations? Are we still
>> guarantying the best performances?
>>
>> Also we have to guarantee, that the TSO and SG are always working. Another
>> point is the buffer sizes that
>> can be different among platforms.
>>
>> The problem  below reported by Corentin push me to think that there is a bug,
>> so we should
>> understand when this has been introduced and if likely fixed by some
>> configuration we are
>> not take care right now.
>>
>> ndesc_get_rx_status: Oversized frame spanned multiple buffers"
> 
> I wonder if this could be easily triggered by getting a big file via FTP. So not
> properly related on performance benchs

I am going to do that test and check it out and also run iperf a couple of
times. I am counting on doing this today and send you later the results. If
anyone gets results sooner please share.

> 
> peppe
> 
>>
>>
>> Best Regards
>> Peppe
>>
> 

Thanks.
