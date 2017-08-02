From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 1/2] [for 4.13] net: qcom/emac: disable flow control
 autonegotiation by default
Date: Wed, 2 Aug 2017 09:21:42 -0500
Message-ID: <77de100a-42b1-1e0d-6545-cadb0067eec6@codeaurora.org>
References: <1501623460-3575-1-git-send-email-timur@codeaurora.org>
 <1501623460-3575-2-git-send-email-timur@codeaurora.org>
 <063D6719AE5E284EB5DD2968C1650D6DD00490C0@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight@ACULAB.COM>,
        "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:45566 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752464AbdHBOVo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 10:21:44 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD00490C0@AcuExch.aculab.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/2/17 8:48 AM, David Laight wrote:
> If the nearby switches cannot handle pause frames, then the MAC shouldn't
> be sending them at all.

There's no way for me to know whether the switches can handle the pause 
frames or not.  You would think that sending one multicast pause frame 
ever 33ms would not overload a switch, but in our lab it does.

This is why I changed the default to disable sending pause frames.

> They
> 
> I suspect that they should only ever be sent if the phy autonegotiation
> indicates that they are supported.

Or if you manually enable them.  That's why I changed to default: the 
MAC is now configured by default to accept pause frames but not send them.

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the
Code Aurora Forum, hosted by The Linux Foundation.
