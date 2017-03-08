From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: [PATCH net-next 1/1] net: rmnet_data: Initial implementation
Date: Wed, 08 Mar 2017 14:25:19 -0700
Message-ID: <567a5c64abe80b82d58ef8c94f249848@codeaurora.org>
References: <1487907054-15129-1-git-send-email-subashab@codeaurora.org>
 <1487907054-15129-2-git-send-email-subashab@codeaurora.org>
 <20170307.121417.1835754162077665274.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com,
        netdev-owner@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:56462 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752211AbdCHWTr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 17:19:47 -0500
In-Reply-To: <20170307.121417.1835754162077665274.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Inside the kernel you should use "u32", "u16", "u8", etc. for purely
> internal things, and for datastructures exported to userspace you
> should use "__u32", "__u16", "__u8".
> 
> Furthermore, if the members have specific endianness you should
> properly use the "__le32", "__le16", "__be32", "__be16" etc. types.
> 
> 
> Please use netlink for device instantiation and configuration
> rather than ioctls.

Hi David

Thanks for reviewing. I'll post v2 with these changes.
