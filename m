From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH v2 1/4] net: phy: at803x: Document RGMII RX and TX clock
 delay issues
Date: Fri, 21 Jul 2017 09:06:44 -0500
Message-ID: <1c35e791-c181-2855-8463-b3b0ef5367a2@codeaurora.org>
References: <2617d673-ef81-5e7f-4730-ed3aa3f1c2c6@sigmadesigns.com>
 <051653a2-946f-6a0b-4cff-b403d1197038@sigmadesigns.com>
 <a9d3777c-1752-d79b-8302-d09c5f736a9f@codeaurora.org>
 <db666f79-5ee3-f136-527e-aeb9cc6425b7@sigmadesigns.com>
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
Received: from smtp.codeaurora.org ([198.145.29.96]:58174 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751464AbdGUOGt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2017 10:06:49 -0400
In-Reply-To: <db666f79-5ee3-f136-527e-aeb9cc6425b7@sigmadesigns.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/21/17 8:29 AM, Marc Gonzalez wrote:
> I don't understand what you're saying.
> 
> It is a correct observation that the code enabling
> RGMII RX clock delay is a NOP, since that bit will
> always be set at that point.
> 
> The spec for the 8035 (I haven't checked for 8030 and 8031,
> is that what you meant by "other systems"?) states that
> Sel_clk125m_dsp, which is described as:
> "Control bit for rgmii interface rx clock delay"
> is 1 after HW reset, 1 after SW reset.
> 
> So my statement "RX clock delay is enabled at reset"
> is universally true. It's not just on some systems.

Ok, taken out of context, the comment doesn't really explain why the 
code is the way it is.  I'm not really happy about the word "assumes". 
Maybe you should add a sentence explaining when the code is NOT a no-op.

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the
Code Aurora Forum, hosted by The Linux Foundation.
