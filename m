From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev: octeon_mgmt: ISO C90 forbids mixed
 declarations and code
Date: Sat, 13 Sep 2014 16:03:02 -0400 (EDT)
Message-ID: <20140913.160302.698126980021738731.davem@davemloft.net>
References: <1410635108-3589-1-git-send-email-xypron.glpk@gmx.de>
	<1410635472.917.1.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xypron.glpk@gmx.de, david.daney@cavium.com, luka@openwrt.org,
	willemb@google.com, rmk+kernel@arm.linux.org.uk,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1410635472.917.1.camel@joe-AO725>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Sat, 13 Sep 2014 12:11:12 -0700

> On Sat, 2014-09-13 at 21:05 +0200, Heinrich Schuchardt wrote:
>> Compiling with OCTEON_MGMT_ETHERNET gives a warning
>> drivers/net/ethernet/octeon/octeon_mgmt.c:295:4:
>> warning: ISO C90 forbids mixed declarations and code
>> [-Wdeclaration-after-statement]
> 
> Maybe better to move the memset after the declaration.

Totally agree, keep the variable in the innermost scope
in which it is used.
