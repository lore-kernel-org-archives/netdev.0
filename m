From: Romain Perier <romain.perier@collabora.com>
Subject: Re: [PATCH 2/2] net: phy: Don't use drv when it is NULL in
 phy_attached_print
Date: Mon, 21 Aug 2017 13:46:07 +0200
Message-ID: <8a710dd3-0c84-5e45-28e4-e56be5883e68@collabora.com>
References: <20170821075235.28473-1-romain.perier@collabora.com>
 <20170821075235.28473-3-romain.perier@collabora.com>
 <5c7d444c-427f-7a4d-8603-02bd4dc4b909@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5c7d444c-427f-7a4d-8603-02bd4dc4b909@cogentembedded.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,


Le 21/08/2017 à 11:45, Sergei Shtylyov a écrit :
> Hello!
>
> On 8/21/2017 10:52 AM, Romain Perier wrote:
>
>> Currently, if this logging function is used prior the phy driver is
>> binded to the phy device (that is usually done from .ndo_open),
>
>    s/binded/bound/.
>
>> 'phydev->drv' might be NULL, resulting in a kernel crash. That is
>> typically the case in the stmmac driver, info about the phy is displayed
>> during the registration of the MDIO bus, and then genphy driver is
>> binded
>
>    Likewise.
>
>> to this phydev when .ndo_open is called.
>>
>> This commit fixes the issue by using the right genphy driver, when
>> phydev->drv is NULL.
>>
>> Fixes: commit fbca164776e4 ("net: stmmac: Use the right logging functi")
>
>    "Commit" not needed here.

Fixed, thanks

Romain
