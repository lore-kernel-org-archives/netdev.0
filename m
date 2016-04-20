From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/1] drivers: net: cpsw: Fix NULL pointer
 dereference with two slave PHYs
Date: Tue, 19 Apr 2016 20:15:50 -0400 (EDT)
Message-ID: <20160419.201550.902520333910307559.davem@davemloft.net>
References: <1460987606-18125-1-git-send-email-andrew.goodbody@cambrionix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: andrew.goodbody@cambrionix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460987606-18125-1-git-send-email-andrew.goodbody@cambrionix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Goodbody <andrew.goodbody@cambrionix.com>
Date: Mon, 18 Apr 2016 14:53:25 +0100

> This is a fix for a NULL pointer dereference from cpsw which is triggered
> by having two slave PHYs attached to a cpsw network device. The problem is
> due to only maintaining a single reference to a PHY node in the prive data
> which gets overwritten by the second PHY probe. So move the PHY node
> reference to the individual slave data so that there is now one per slave.
> 
> v1 had a problem that data->slaves was used before it had been filled in

I already applied v1 the other day, so you need to send me a relative
patch rather than a whole new one.

Thanks.
