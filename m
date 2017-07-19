From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 1/2] net: phy: at803x: Fix RGMII RX and TX clock delays
 setup
Date: Wed, 19 Jul 2017 12:49:50 -0500
Message-ID: <d0b7027d-1306-a114-00c0-8e3cb01d4d0e@codeaurora.org>
References: <b332dc3e-4478-e34b-2b3f-226aad8a11d4@sigmadesigns.com>
 <33ed5f4f-9939-dc00-b973-db39c16f2393@sigmadesigns.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>,
        "David S. Miller" <davem@davemloft.net>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>,
        Mason <slash.tmp@free.fr>
To: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, Mans Rullgard <mans@mansr.com>,
        Martin Blumenstingl <martin.blumenstingl@gmail.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        Daniel Mack <zonque@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:35476 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754469AbdGSRt4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 13:49:56 -0400
In-Reply-To: <33ed5f4f-9939-dc00-b973-db39c16f2393@sigmadesigns.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/19/2017 10:31 AM, Marc Gonzalez wrote:
> The current code supports enabling RGMII RX and TX clock delays.
> The unstated assumption is that these settings are disabled by
> default at reset, which is not the case.
> 
> RX clock delay is enabled at reset. And TX clock delay "survives"
> across SW resets. Thus, if the bootloader enables TX clock delay,
> it will remain enabled at reset in Linux.
> 
> Provide disable functions to configure the RGMII clock delays
> exactly as specified in the fwspec.

I only use SGMII mode, and I tested and can confirm that this patch does 
not break SGMII, so:

Acked-by: Timur Tabi <timur@codeaurora.org>

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
