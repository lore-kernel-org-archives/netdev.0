From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] mac802154: constify ieee802154_llsec_ops structure
Date: Mon, 4 Jan 2016 11:41:10 -0800
Message-ID: <7E0080F5-62E2-475F-A861-7B58DC87131E@holtmann.org>
References: <1450906592-9203-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0 (Mac OS X Mail 9.2 \(3112\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Alexander Aring <alex.aring@gmail.com>,
	kernel-janitors@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	linux-wpan@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1450906592-9203-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Julia,

> The ieee802154_llsec_ops structure is never modified, so declare it as
> const.
> 
> Done with the help of Coccinelle.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> ---
> include/net/ieee802154_netdev.h |    2 +-
> net/mac802154/mac_cmd.c         |    2 +-
> 2 files changed, 2 insertions(+), 2 deletions(-)

patch has been applied to bluetooth-next tree.

Regards

Marcel
