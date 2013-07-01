From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: fec: Fix multicast list setup in fec_restart().
Date: Mon, 01 Jul 2013 13:29:53 -0700 (PDT)
Message-ID: <20130701.132953.922899681299706282.davem@davemloft.net>
References: <61455.62.178.124.14.1371832855.squirrel@mail.theobroma-systems.com>
	<1372360703-20526-1-git-send-email-christoph.muellner@theobroma-systems.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: festevam@gmail.com, linux-kernel@vger.kernel.org,
	grant.likely@linaro.org, rob.herring@calxeda.com,
	fabio.estevam@freescale.com, netdev@vger.kernel.org
To: christoph.muellner@theobroma-systems.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372360703-20526-1-git-send-email-christoph.muellner@theobroma-systems.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Muellner <christoph.muellner@theobroma-systems.com>
Date: Thu, 27 Jun 2013 21:18:23 +0200

> Setup the multicast list of the net_device instead of
> clearing it blindly. This restores the multicast groups
> in case of a link down/up event or when resuming from
> suspend.
> 
> Signed-off-by: Christoph Muellner <christoph.muellner@theobroma-systems.com>

Applied.
