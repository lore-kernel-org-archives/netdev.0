From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH net-next] net: fix dma operation mode config for older
 versions
Date: Tue, 21 Mar 2017 17:58:47 +0000
Message-ID: <3a41c4cf-83aa-5cb9-8009-d7fd6d94c86e@synopsys.com>
References: <3b8aeab69d2987db68c74f48a3ac13c7241e1542.1490117473.git.jpinto@synopsys.com>
 <a9aa6a41-d5d1-80fd-6d8c-74db98ee7dec@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: <peppe.cavallaro@st.com>, <alexandre.torgue@st.com>,
        <clabbe.montjoie@gmail.com>, <thierry.reding@gmail.com>,
        <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay.synopsys.com ([198.182.47.9]:54028 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932333AbdCUSHE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 14:07:04 -0400
In-Reply-To: <a9aa6a41-d5d1-80fd-6d8c-74db98ee7dec@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Às 5:53 PM de 3/21/2017, Sergei Shtylyov escreveu:
> On 03/21/2017 08:36 PM, Joao Pinto wrote:
> 
>> This patch fixes a bug introduced in commit:
>> 6deee22 (net: stmmac: prepare dma op mode config for multiple queues)
> 
>    Need 12 hex digits and the commit summary enclosed into ("").
> 
>> The dma operation mode configuration routine was wrongly moved to a
>> function (stmmac_mtl_configuration) that is only executed if the
>> core version is >= 4.00.
>>
>> Reported-by: Corentin Labbe <clabbe.montjoie@gmail.com>
>>
>> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
> [...]
> 
> MBR, Sergei
> 

Thanks for the tip, going to send a v2.

Joao
