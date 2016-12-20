From: Timur Tabi <timur@codeaurora.org>
Subject: Re: Which ethtool methods should I implement?
Date: Tue, 20 Dec 2016 10:38:47 -0600
Message-ID: <58595E97.40502@codeaurora.org>
References: <58588982.5030006@codeaurora.org>
 <a7fbf45a-3b74-cbb8-f239-44c35717aabd@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:50564 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758627AbcLTQit (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2016 11:38:49 -0500
In-Reply-To: <a7fbf45a-3b74-cbb8-f239-44c35717aabd@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/19/2016 07:40 PM, Florian Fainelli wrote:
> Ideally, everything that is supported by your HW, but I would with the
> basic essential stuff that you would need in case someone reports
> problems with your driver like:
>
> - statistics (MAC for sure) and PHY (if possible), -S
> - ability to restart auto-negotation (-r)
> - reporting of driver information (-i)
> - support toggling and reporting NETIF_F_* features -k/-K

Thanks, I'll get this done soon.

I'm confused about netdev_set_default_ethtool_ops().  Is this a function 
that drivers are supposed to call?  I only see one driver use it.  Other 
drivers just set netdev->ethtool_ops manually.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
