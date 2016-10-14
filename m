From: Timur Tabi <timur@codeaurora.org>
Subject: Re: Need help with mdiobus_register and phy
Date: Fri, 14 Oct 2016 06:38:47 -0500
Message-ID: <5800C3C7.60705@codeaurora.org>
References: <5800159B.3080708@codeaurora.org> <20161014040641.GE5822@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:37296 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754270AbcJNLiu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 07:38:50 -0400
In-Reply-To: <20161014040641.GE5822@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Lunn wrote:
> Normally, a sleeping PHY does respond to MDIO. Otherwise, how do you
> wake it?
>
> So i assume this phy has some other means to wake it. What is this
> means?

I'm guessing that someone has to call phy_resume() before/during the 
call to mdiobus_register, but I don't see how that's possible.

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the
Code Aurora Forum, hosted by The Linux Foundation.
