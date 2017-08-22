From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next,0/4] hv_netvsc: Ethtool handler to change UDP
 hash levels
Date: Tue, 22 Aug 2017 14:08:27 -0700 (PDT)
Message-ID: <20170822.140827.1102230677662395664.davem@davemloft.net>
References: <1503368560-14331-1-git-send-email-haiyangz@exchange.microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, olaf@aepfle.de,
        vkuznets@redhat.com, linux-kernel@vger.kernel.org
To: haiyangz@microsoft.com, haiyangz@exchange.microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503368560-14331-1-git-send-email-haiyangz@exchange.microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Date: Mon, 21 Aug 2017 19:22:36 -0700

> From: Haiyang Zhang <haiyangz@microsoft.com>
> 
> The patch set adds the functions to switch UDP hash level between
> L3 and L4 by ethtool command. UDP over IPv4 and v6 can be set
> differently. The default hash level is L4. We currently only
> allow switching TX hash level from within the guests.
> 
> The ethtool callback function is triggered by command line, and
> update the per device variables of the hash level.
> 
> On Azure, fragmented UDP packets is not yet supported with L4
> hashing, and may have high packet loss rate. Using L3 hashing is
> recommended in this case. This ethtool option allows a user to
> make this selection.

Series applied, thanks.
