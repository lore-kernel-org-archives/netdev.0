From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH v2 1/4] net: phy: at803x: Document RGMII RX and TX clock
 delay issues
Date: Fri, 21 Jul 2017 08:20:39 -0500
Message-ID: <a9d3777c-1752-d79b-8302-d09c5f736a9f@codeaurora.org>
References: <2617d673-ef81-5e7f-4730-ed3aa3f1c2c6@sigmadesigns.com>
 <051653a2-946f-6a0b-4cff-b403d1197038@sigmadesigns.com>
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
Received: from smtp.codeaurora.org ([198.145.29.96]:58724 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753343AbdGUNUn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2017 09:20:43 -0400
In-Reply-To: <051653a2-946f-6a0b-4cff-b403d1197038@sigmadesigns.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/21/17 6:25 AM, Marc Gonzalez wrote:
> +	 * NB: This code assumes that RGMII RX clock delay is disabled
> +	 * at reset, but actually, RX clock delay is enabled at reset.

Could we change this to say, "RX clock delay is enabled at reset on some 
systems."?  Otherwise, it implies that the code is wrong 100% of the 
time and should be fixed, not documented.

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the
Code Aurora Forum, hosted by The Linux Foundation.
