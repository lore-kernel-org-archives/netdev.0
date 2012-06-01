From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] 8139cp/8139too: terminate the eeprom access with
 the right opmode
Date: Fri, 01 Jun 2012 14:23:17 -0400 (EDT)
Message-ID: <20120601.142317.1843610571282799477.davem@davemloft.net>
References: <20120601041939.4311.55827.stgit@dhcp-8-146.nay.redhat.com>
	<20120601041948.4311.42372.stgit@dhcp-8-146.nay.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mst@redhat.com
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120601041948.4311.42372.stgit@dhcp-8-146.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Fri, 01 Jun 2012 12:19:48 +0800

> Currently, we terminate the eeprom access through clearing the CS by:
> 
> RTL_W8 (Cfg9346, ~EE_CS); or writeb (~EE_CS, ee_addr);
> 
> This would left the eeprom into "Config. Register Write Enable:"
> state which is not expcted as the highest two bits were set to
> 0x11 ( expected is the "Normal" mode (0x00)). Solving this by write
> 0x0 instead of ~EE_CS when terminating the eeprom access.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied.
