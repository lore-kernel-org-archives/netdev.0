From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 1/2] [for 4.13] net: qcom/emac: disable flow control
 autonegotiation by default
Date: Wed, 2 Aug 2017 20:00:04 -0500
Message-ID: <6f612384-ec3a-3ac0-4ffe-227973549ac2@codeaurora.org>
References: <290fdd25-7e05-57c8-8f89-52bb3bae1e59@codeaurora.org>
 <20170802.113531.1671960264039506111.davem@davemloft.net>
 <3c31277c-93c4-c0a5-cf0d-7270d07c432c@codeaurora.org>
 <20170802.161536.699853895820311600.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:34062 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751174AbdHCBAG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 21:00:06 -0400
In-Reply-To: <20170802.161536.699853895820311600.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/2/17 6:15 PM, David Miller wrote:

> So you don't want to run a proper watchdog on your systems?
> You want them to just hang there and wait for someone to
> notice instead?

This is for internal development.  We noticed the problem first during 
debugging, when we would halt a core for more than a couple minutes. 
Then the entire lab network would go down.

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the
Code Aurora Forum, hosted by The Linux Foundation.
