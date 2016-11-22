From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 2/2] net: qcom/emac: add support for the Qualcomm
 Technologies QDF2400
Date: Tue, 22 Nov 2016 16:14:13 -0600
Message-ID: <5834C335.4040907@codeaurora.org>
References: <1479769102-27909-1-git-send-email-timur@codeaurora.org>
 <1479769102-27909-3-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, alokc@codeaurora.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:50264 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932273AbcKVWOP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 17:14:15 -0500
In-Reply-To: <1479769102-27909-3-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/21/2016 04:58 PM, Timur Tabi wrote:
> The QDF2432 and the QDF2400 have slightly different internal PHYs,
> so there are some programming differences.  Some of the registers in
> the QDF2400 have moved, and some registers require different values
> during initialization.
>
> Because of the differences, the internal PHY on the QDF2400 has a new
> ACPI HID, QCOM8072.
>
> Signed-off-by: Timur Tabi<timur@codeaurora.org>

There seems to be some disagreement internally as to whether a new HID 
is the right approach.  Please hold off on applying patch [2/2] for now.

Patch [1/2] can be applied, however, if it passes review.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
