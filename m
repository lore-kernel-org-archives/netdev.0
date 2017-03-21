From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: linux-next-20170320 break stmmac on dwmac-sunxi
Date: Tue, 21 Mar 2017 14:49:36 +0000
Message-ID: <3b6997f7-b1b9-a9f5-40b2-dcc7810820c6@synopsys.com>
References: <20170320195406.GA19174@Red>
 <4184996f-08c7-b884-98f5-a9b4abf9e0ba@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        Joao Pinto <Joao.Pinto@synopsys.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        Corentin Labbe <clabbe.montjoie@gmail.com>,
        <alexandre.torgue@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4184996f-08c7-b884-98f5-a9b4abf9e0ba@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Peppe,

Às 2:39 PM de 3/21/2017, Giuseppe CAVALLARO escreveu:
> Hello Corentin
> 
> yes, bisect process is really good approach to me. Pls give us more details.
> Recently the multi DMA channel logic has been added so it could be that
> something is needed to allow your platform to manage the new code.
> Or we introduced some regression. If I have some other idea, I ping you.
> 
> Peppe
> 
> On 3/20/2017 8:54 PM, Corentin Labbe wrote:
>> Hello
>>
>> Just pushed next-20170320 to my boards and stmmac stop working on both intree
>> dwmac-sunxi and my dev dwmac-sun8i.
>> It seems that interrupts never fire, and transmit queue timeout.
>> I will try to bisect this problem but perhaps other people could try to
>> reproduce it.
>>
>> Regards
>> Corentin Labbe
>>
> 

Corentin spotted 2 bugs (dma_op_mode was only being set for core versions >=
4.00 and rx/tx default nº of queues was being set in a place that would not be
accessible if no multiqueue config is added to the DT). Thierry will send a set
of patches to improve soon.

Thanks,
Joao
