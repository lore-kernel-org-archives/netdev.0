From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: netcp: remove call to netif_carrier_(on/off)
 for MAC to Phy interface
Date: Mon, 27 Apr 2015 23:14:29 -0400 (EDT)
Message-ID: <20150427.231429.2129554689807783059.davem@davemloft.net>
References: <1430158363-26870-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: m-karicheri2@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1430158363-26870-1-git-send-email-m-karicheri2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Murali Karicheri <m-karicheri2@ti.com>
Date: Mon, 27 Apr 2015 14:12:43 -0400

> Currently when interface type is MAC to Phy, netif_carrier_(on/off)
> is called which is not needed as Phy lib already updates the carrier
> status to net stack. This is needed only for other interface types
> 
> Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>

Applied.
