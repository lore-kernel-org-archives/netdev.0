From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 3/3] Linn Ethernet packet sniffer driver
Date: Mon, 23 Feb 2015 16:38:54 -0500 (EST)
Message-ID: <20150223.163854.880151768241069377.davem@davemloft.net>
References: <cover.1424698609.git.stathis.voukelatos@linn.co.uk>
	<34013795c99ef50fac3d2c72717971563148578c.1424698609.git.stathis.voukelatos@linn.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: stathis.voukelatos@linn.co.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <34013795c99ef50fac3d2c72717971563148578c.1424698609.git.stathis.voukelatos@linn.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
Date: Mon, 23 Feb 2015 14:26:22 +0000

> Driver for the Ethernet Mii packet sniffer H/W module found in
> the IMG Pistachio SoC.
> 
> Signed-off-by: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>

You really have to explain what this thing does, how it is used,
what APIs are made use of to maniulate this device, etc.

Nobody knows what the packet sniffer module by your company is.

I also anticipate that once you describe adequately how this thing
behaves I won't like it, and I'll prefer that you integrate support
for your device using an exising facility such as AF_PACKET,
extending it if need be.

I am very far away from applying this series at this point, it needs
a lot more work and explanations.
