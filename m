From: Mason <slash.tmp@free.fr>
Subject: Re: [PATCH 2/2] net: ethernet: nb8800: Fix RGMII TX clock delay setup
Date: Mon, 24 Jul 2017 23:21:50 +0200
Message-ID: <54ca7197-780a-68b1-0cf2-88ccc7ce4201@free.fr>
References: <b332dc3e-4478-e34b-2b3f-226aad8a11d4@sigmadesigns.com>
 <61b71d12-4e3a-edbe-1d69-c66e7cf46d8e@sigmadesigns.com>
 <yw1xzic0qrcg.fsf@mansr.com> <001a7afd-364d-359e-1478-e057c9083f73@free.fr>
 <d8121f82-dffd-22c7-1209-a3c2329703e5@gmail.com>
 <05cbc32e-a4af-1c81-128b-bc5d2206d24a@free.fr>
 <bf484952-15ae-b385-6b54-4d07b3bc2b29@gmail.com>
 <54f5bd21-766d-d9de-3b15-a01fd5ee6035@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Mans Rullgard <mans@mansr.com>,
        Marc Gonzalez <marc_gonzalez@sigmadesigns.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Martin Blumenstingl <martin.blumenstingl@gmail.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        Timur Tabi <timur@codeaurora.org>,
        Daniel Mack <zonque@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>,
        "David S. Miller" <davem@davemloft.net>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:62038 "EHLO smtp2-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753123AbdGXVWZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Jul 2017 17:22:25 -0400
In-Reply-To: <54f5bd21-766d-d9de-3b15-a01fd5ee6035@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20/07/2017 14:33, Mason wrote:

> As [Florian] pointed out, the spec states that the
> "Data to Clock input Skew (at Receiver)"
> must be within [ 1.0, 2.6 ] ns.
> 
> I understand that 2 ns is 1/4 of a 125 MHz period,
> but it's not clear to me why the above interval is
> centered at 1.8 instead of 2.0 ns.
> 
> Also, the AR8035 PHY offers 4 possible TX clock delays:
> { 0.25, 1.3, 2.4, 3.4 } according to their doc.
> The two extremes are outside the interval, when would
> they be useful? In case the transmitter adds "bad" skew?
> 
> Why doesn't the PHY support 1.8/2.0? Is it perhaps
> unable to, because of PLL limitations?

I haven't yet found answers for these questions.

- Why is the interval centered at 1.8 instead of 2.0 ns?
- What use are 0.25 ns and 3.4 ns skew?
- Why doesn't the PHY support a "recommended" value like 1.8 ns?

Does anyone have pointers to good resources?

Regards.
