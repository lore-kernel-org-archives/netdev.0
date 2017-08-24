From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: stmmac: Delete dead code for MDIO registration
Date: Thu, 24 Aug 2017 09:34:21 -0700 (PDT)
Message-ID: <20170824.093421.154694549501118093.davem@davemloft.net>
References: <20170823085058.23333-1-romain.perier@collabora.com>
        <d803f188-826b-706c-2d28-18ee87b8aa0d@gmail.com>
        <10e0ebf9-b412-8547-d0d7-01a958edbcd9@collabora.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: f.fainelli@gmail.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, andrew@lunn.ch, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: romain.perier@collabora.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <10e0ebf9-b412-8547-d0d7-01a958edbcd9@collabora.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Romain Perier <romain.perier@collabora.com>
Date: Thu, 24 Aug 2017 08:49:18 +0200

> Le 23/08/2017 à 18:46, Florian Fainelli a écrit :
>> On 08/23/2017 01:50 AM, Romain Perier wrote:
>>> This code is no longer used, the logging function was changed by commit
>>> fbca164776e4 ("net: stmmac: Use the right logging functi"). It was
>>> previously showing information about the type if the IRQ, if it's polled,
>>> ignored or a normal interrupt. As we don't want information loss, I have
>>> moved this code to phy_attached_print().
>>>
>>> Fixes: fbca164776e4 ("net: stmmac: Use the right logging functi")
>> For future submissions, do not truncate the commit subject that you are
>> referencing.
> 
> Even if it exceeds 72 characters ?

Yes, always.
