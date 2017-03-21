From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: linux-next-20170320 break stmmac on dwmac-sunxi
Date: Tue, 21 Mar 2017 15:39:00 +0100
Message-ID: <4184996f-08c7-b884-98f5-a9b4abf9e0ba@st.com>
References: <20170320195406.GA19174@Red>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        Joao Pinto <Joao.Pinto@synopsys.com>
To: Corentin Labbe <clabbe.montjoie@gmail.com>,
        <alexandre.torgue@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170320195406.GA19174@Red>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Corentin

yes, bisect process is really good approach to me. Pls give us more details.
Recently the multi DMA channel logic has been added so it could be that
something is needed to allow your platform to manage the new code.
Or we introduced some regression. If I have some other idea, I ping you.

Peppe

On 3/20/2017 8:54 PM, Corentin Labbe wrote:
> Hello
>
> Just pushed next-20170320 to my boards and stmmac stop working on both intree dwmac-sunxi and my dev dwmac-sun8i.
> It seems that interrupts never fire, and transmit queue timeout.
> I will try to bisect this problem but perhaps other people could try to reproduce it.
>
> Regards
> Corentin Labbe
>
