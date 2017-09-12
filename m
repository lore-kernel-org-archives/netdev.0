From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 2/2] net: qcom/emac: add software control for pause frame
 mode
Date: Tue, 12 Sep 2017 17:07:19 -0500
Message-ID: <f84025d9-bb29-bfbe-2a01-664b086e9458@codeaurora.org>
References: <1501623460-3575-1-git-send-email-timur@codeaurora.org>
 <1501623460-3575-3-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:59170 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751385AbdILWHV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2017 18:07:21 -0400
In-Reply-To: <1501623460-3575-3-git-send-email-timur@codeaurora.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/01/2017 04:37 PM, Timur Tabi wrote:
> The EMAC has the option of sending only a single pause frame when
> flow control is enabled and the RX queue is full.  Although sending
> only one pause frame has little value, this would allow admins to
> enable automatic flow control without having to worry about the EMAC
> flooding nearby switches with pause frames if the kernel hangs.
> 
> The option is enabled by using the single-pause-mode private flag.
> 
> Signed-off-by: Timur Tabi<timur@codeaurora.org>

Dave,

I don't see this patch in net-next.  Can you pick it up for 4.14?

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
