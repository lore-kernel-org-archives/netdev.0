From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: calxedaxgmac: fix rx ring handling when OOM
Date: Fri, 29 Mar 2013 15:29:58 -0400 (EDT)
Message-ID: <20130329.152958.576829381792957267.davem@davemloft.net>
References: <1364506365-13689-1-git-send-email-robherring2@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rob.herring@calxeda.com
To: robherring2@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364506365-13689-1-git-send-email-robherring2@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rob Herring <robherring2@gmail.com>
Date: Thu, 28 Mar 2013 16:32:44 -0500

> From: Rob Herring <rob.herring@calxeda.com>
> 
> If skb allocation for the rx ring fails repeatedly, we can reach a point
> were the ring is empty. In this condition, the driver is out of sync with
> the h/w. While this has always been possible, the removal of the skb
> recycling seems to have made triggering this problem easier.
> 
> Signed-off-by: Rob Herring <rob.herring@calxeda.com>

Applied.
