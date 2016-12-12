From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: Synopsys Ethernet QoS
Date: Mon, 12 Dec 2016 15:11:01 +0100
Message-ID: <c393b67c-b8f4-78d2-20ba-22c5978ff385@st.com>
References: <2df7a6dd-1128-d1d6-bf61-891f76cf7200@synopsys.com>
 <20161209.103327.1742213347114742435.davem@davemloft.net>
 <93b73b79-36aa-56b8-f975-b890b7a48bd1@synopsys.com>
 <20161209.104152.1969880574279771010.davem@davemloft.net>
 <CAHp75VcKURaTQX9=SY8+46GGATuwO1oXAi8eMS+uwk58sjKx5Q@mail.gmail.com>
 <3aee5a67-5e19-34e6-1719-ff13c7b914ea@gmail.com>
 <CAHp75VfT9B3O5jU0eHoKtgYc48K2ZjCQ-g9ZQ9nX1Hew6tz-zw@mail.gmail.com>
 <556353b7-c847-7549-626d-3c324063647e@gmail.com>
 <f5357ea2-a295-ab08-046e-f8b8f6ca4344@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>, <lars.persson@axis.com>,
        <rabin.vincent@axis.com>, netdev <netdev@vger.kernel.org>,
        <CARLOS.PALMINHA@synopsys.com>, <Jie.Deng1@synopsys.com>
To: Joao Pinto <Joao.Pinto@synopsys.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andy Shevchenko <andy.shevchenko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:30988 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751640AbcLLOLM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2016 09:11:12 -0500
In-Reply-To: <f5357ea2-a295-ab08-046e-f8b8f6ca4344@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello All.

On 12/12/2016 11:19 AM, Joao Pinto wrote:
> Hi,
>
> Às 1:44 AM de 12/10/2016, Florian Fainelli escreveu:
>> Le 12/09/16 à 16:16, Andy Shevchenko a écrit :
>>> On Sat, Dec 10, 2016 at 12:52 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>>>
>>>> It's kind of sad that customers of that IP (stmmac, amd-xgbe, sxgbe)
>>>
>>>> did
>>>> actually pioneer the upstreaming effort, but it is good to see people
>>>> from Synopsys willing to fix that in the future.
>>>
>>> Wait, you would like to tell that we have more than 2 drivers for the
>>> same (okay, same vendor) IP?!
>>> It's better to unify them earlier, than have n+ copies.
>>
>> Unfortunately that is the case, see this email:
>>
>> https://www.mail-archive.com/netdev@vger.kernel.org/msg142796.html
>>
>> dwc_eth_qos and stmmac have some overlap. There seems to be work
>> underway to unify these two to begin with.
>>
>>>
>>> P.S. Though, I don't see how sxgbe got in the list. First glance on
>>> the code doesn't show similarities.
>>
>> Well samsung/sxgbe looks potentially similar to amd/xgbe, but that's
>> just my cursory look at the code, it may very well be something entirely
>> different. The descriptor formats just look suspiciously similar.
>>
>
> Thank you for your inputs! Renaming seems to be a hotspot. I agree that maybe
> instead of renaming (breaking retro-compatibility as David and Florian
> mentioned), the best is to move stmmac to synopsys/ after merging *qos* and
> removing it. As Florian mentioned, git is capable of detecting folder restructured.
>
> @Rabin Vincent: Hi Rabin. Since Axis is more familiar with the synopsys/*qos*
> driver would it be possible for you to make an initial analysis of what has to
> be merged into Stmmac? This way the development would speed-up.

my priority on this topic was to help Joao to easily port his
platform on stmmac and IIUC we already achieved some results.
For several reasons, we had discussed to support GMAC IP with stmmac
and, as first stage, to evaluate and port the relevant changes
from  dwc_eth_qos.c. If renaming of moving the stmmac should be
discussed later and for sure all together could find the best solution
in the right moment where some critical patches and supports are in
place.

As highlighted by Jie, the XLGMAC is another IP (that I do not know
at all so I cannot say if there is some way to support it
by using stmmac).

Thanks a lot.

peppe

>
> Thanks to all.
>
> Joao
>
