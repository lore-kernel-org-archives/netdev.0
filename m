From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] davinci_emac: Fix use after free in davinci_emac_remove
Date: Tue, 03 Aug 2010 21:36:16 -0700 (PDT)
Message-ID: <20100803.213616.48488045.davem@davemloft.net>
References: <1280861625-4804-1-git-send-email-weil@mail.berlios.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chaithrika@ti.com, srk@ti.com,
	khilman@deeprootsystems.com, linux-kernel@vger.kernel.org
To: weil@mail.berlios.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1280861625-4804-1-git-send-email-weil@mail.berlios.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Weil <weil@mail.berlios.de>
Date: Tue,  3 Aug 2010 20:53:45 +0200

> free_netdev finally calls kfree which makes the contents
> of ndev and priv (private data contained in ndev) invalid.
> 
> So iounmap should be called before free_netdev.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Chaithrika U S <chaithrika@ti.com>
> Cc: Sriramakrishnan <srk@ti.com>
> Cc: Kevin Hilman <khilman@deeprootsystems.com>
> Cc: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Signed-off-by: Stefan Weil <weil@mail.berlios.de>

I'll apply this, thanks.
