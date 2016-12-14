From: Jie Deng <Jie.Deng1@synopsys.com>
Subject: Re: stmmac driver...
Date: Wed, 14 Dec 2016 16:26:48 +0800
Message-ID: <14869a7a-6fdd-0b94-d575-a2b44ac60700@synopsys.com>
References: <20161207.130654.1484281922991494182.davem@davemloft.net>
 <35edb551-518e-f59f-7a9e-db108d8f42a7@st.com>
 <8d624fd3-8440-5b8a-ee8d-558a671eec60@synopsys.com>
 <d8d00654-a07e-2992-a911-3b88f1d3d3ac@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <CARLOS.PALMINHA@synopsys.com>, <netdev@vger.kernel.org>,
        "Giuseppe CAVALLARO" <peppe.cavallaro@st.com>
To: Jie Deng <Jie.Deng1@synopsys.com>,
        David Miller <davem@davemloft.net>, <alexandre.torgue@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay.synopsys.com ([198.182.60.111]:34864 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755001AbcLNI1I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 03:27:08 -0500
In-Reply-To: <d8d00654-a07e-2992-a911-3b88f1d3d3ac@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

>>>> Giuseppe and Alexandre,
>>>>
>>>> There are a lot of patches and discussions happening around the stammc
>>>> driver lately and both of you are listed as the maintainers.
>>>>
>>>> I really need prompt and conclusive reviews of these patch submissions
>>>> from you, and participation in all discussions about the driver.
>>>
>>> yes we are trying to do the best.
>>>
>>>> Otherwise I have only three things I can do: 1) let the patches rot in
>>>> patchwork for days 2) trust that the patches are sane and fit your
>>>> desires and goals and just apply them or 3) reject them since they
>>>> aren't being reviewed properly.
>>>
>>> at this stage, I think the best is: (3).
>> I think the patches David mentioned also included XLGMAC. He sent this email
>> before I explained QoS and XLGMAC were different IPs. Do you mind we do XLGMAC
>> development under drivers/net/ethernet/synopsys/ ? I think we don't have
>> conflict since we will keep QoS development in stmmac.
>
> Great. Many thanks for the clarification :-)
>
> Regards
> Peppe
>
Do you agree that we do XLGMAC  development under drivers/net/ethernet/synopsys/
in the future ?
There is no conflict of interest since this is a new IP without driver. As you
see, there are several drivers for QoS (GMAC) and several drivers for XGMAC. We
want to avoid this situation for the new IP XLGMAC.

Regards,
Jie
