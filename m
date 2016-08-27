From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] [v9] net: emac: emac gigabit ethernet controller driver
Date: Sat, 27 Aug 2016 07:26:39 -0500
Message-ID: <57C186FF.6090702@codeaurora.org>
References: <1472161143-26417-1-git-send-email-timur@codeaurora.org>
 <20160826.212939.1362447220540461922.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
        shankerd@codeaurora.org, vikrams@codeaurora.org,
        cov@codeaurora.org, gavidov@codeaurora.org, robh+dt@kernel.org,
        andrew@lunn.ch, bjorn.andersson@linaro.org, mlangsdo@redhat.com,
        jcm@redhat.com, agross@codeaurora.org, f.fainelli@gmail.com,
        LinoSanfilippo@gmx.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:43202 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751316AbcH0M0n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 Aug 2016 08:26:43 -0400
In-Reply-To: <20160826.212939.1362447220540461922.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Timur Tabi <timur@codeaurora.org>
> Date: Thu, 25 Aug 2016 16:39:03 -0500
>
>> +static const u8 duuid[] = {
>> +	0x77, 0x79, 0x60, 0xbf,
>> +	0x2d, 0xab,
>> +	0x9d, 0x4b,
>> +	0x94, 0xf0,
>> +	0xe1, 0x11, 0x98, 0x01, 0xa2, 0xba
>> +};
>
> This seems to be completely unused, please remove it.

Sorry, I missed that during my cleanup.  I'll remove it in v10.

I wonder why my compiler didn't complain about the unused static.

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the
Code Aurora Forum, hosted by The Linux Foundation.
