From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/8] add missing of_node_put
Date: Mon, 26 Oct 2015 22:08:48 -0700 (PDT)
Message-ID: <20151026.220848.1827888098875824300.davem@davemloft.net>
References: <1445781427-7110-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, kernel-janitors@vger.kernel.org,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, soren.brinkmann@xilinx.com,
	linux-media@vger.kernel.org, linux@arm.linux.org.uk,
	thomas.petazzoni@free-electrons.com, andrew@lunn.ch,
	bhelgaas@google.com, jason@lakedaemon.net
To: Julia.Lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445781427-7110-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Sun, 25 Oct 2015 14:56:59 +0100

> The various for_each device_node iterators performs an of_node_get on each
> iteration, so a break out of the loop requires an of_node_put.
> 
> The complete semantic patch that fixes this problem is
> (http://coccinelle.lip6.fr):
 ...

Series applied, thanks a lot Julia.
