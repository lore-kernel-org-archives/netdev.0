From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: netcp: Fixes SGMII reset on network interface
 shutdown
Date: Mon, 27 Jul 2015 01:14:36 -0700 (PDT)
Message-ID: <20150727.011436.1250682506547894597.davem@davemloft.net>
References: <1437764549-3857-1-git-send-email-w-kwok2@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: m-karicheri2@ti.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: w-kwok2@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1437764549-3857-1-git-send-email-w-kwok2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: WingMan Kwok <w-kwok2@ti.com>
Date: Fri, 24 Jul 2015 15:02:29 -0400

> This patch asserts SGMII RTRESET, i.e. resetting the SGMII Tx/Rx
> logic,  during network interface shutdown to avoid having the
> hardware wedge when shutting down with high incoming traffic rates.
> This is cleared (brought out of RTRESET) when the interface is
> brought back up.
> 
> 
> Signed-off-by: WingMan Kwok <w-kwok2@ti.com>

Applied.
