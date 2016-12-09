From: Niklas Cassel <nks.gnu@gmail.com>
Subject: Re: stmmac driver...
Date: Fri, 9 Dec 2016 11:50:50 +0100
Message-ID: <CAD5ja62JQzjkM2VD7N+D0Vz3tOM7y9dZ43Fd_+ARz_OzLTOF-w@mail.gmail.com>
References: <20161207.130654.1484281922991494182.davem@davemloft.net>
 <e8370557-b11a-0fe6-f87f-3af2e5990f27@st.com> <20161208.102552.714315690167693892.davem@davemloft.net>
 <59b37368-8670-659a-c257-034f73a83136@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, alexandre.torgue@st.com,
        peppe.cavallaro@st.com, netdev@vger.kernel.org,
        CARLOS.PALMINHA@synopsys.com, Joao.Pinto@synopsys.com
To: Jie Deng <Jie.Deng1@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:34091 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932926AbcLIKuw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 05:50:52 -0500
Received: by mail-wm0-f51.google.com with SMTP id u144so12418583wmu.1
        for <netdev@vger.kernel.org>; Fri, 09 Dec 2016 02:50:52 -0800 (PST)
In-Reply-To: <59b37368-8670-659a-c257-034f73a83136@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Jie Deng


In your cover letter you wrote

dwc-eth-xxx.x
  The DWC ethernet core layer (DWC ECL). This layer contains codes
can be shared by different DWC series ethernet cores

Does this mean that code in dwc-eth-xxx.x is common to all
the different Synopsys IPs, GMAC, XGMAC and XLGMAC ?


Regards,
Niklas

On Fri, Dec 9, 2016 at 11:05 AM, Jie Deng <Jie.Deng1@synopsys.com> wrote:
>
>
> On 2016/12/8 23:25, David Miller wrote:
>> From: Alexandre Torgue <alexandre.torgue@st.com>
>> Date: Thu, 8 Dec 2016 14:55:04 +0100
>>
>>> Maybe I forget some series. Do you have others in mind ?
>> Please see the thread titled:
>>
>> "net: ethernet: Initial driver for Synopsys DWC XLGMAC"
>>
>> which seems to be discussing consolidation of various drivers
>> for the same IP core, of which stmmac is one.
>>
>> I personally am against any change of the driver name and
>> things like this, and wish the people doing that work would
>> simply contribute to making whatever changes they need directly
>> to the stmmac driver.
>>
>> You really need to voice your opinion when major changes are being
>> proposed for the driver you maintain.
>>
> Hi David and Alex,
>
> XLGMAC is not a version of GMAC. Synopsys has several IPs and each IP has
> several versions.
>
> GMAC(QoS): 3.5, 3.7, 4.0, 4.10, 4.20...
> XGMAC: 1.00, 1.10, 1.20, 2.00, 2.10, 2.11...
> XLGMAC (Synopsys DesignWare Core Enterprise Ethernet): this is a new IP.
>
> Regards,
> Jie
>
