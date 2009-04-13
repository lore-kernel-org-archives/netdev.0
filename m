From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] net: bridge: use device address list instead of
 dev_addr
Date: Mon, 13 Apr 2009 15:54:07 -0700 (PDT)
Message-ID: <20090413.155407.12944222.davem@davemloft.net>
References: <20090313183303.GF3436@psychotron.englab.brq.redhat.com>
	<20090413083729.GA23734@psychotron.englab.brq.redhat.com>
	<20090413084407.GD23734@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com, shemminger@linux-foundation.org,
	bridge@lists.linux-foundation.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net, kaber@trash.net,
	mschmidt@redhat.com, dada1@cosmosbay.com, ivecera@redhat.com
To: jpirko@redhat.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754376AbZDMWyb@vger.kernel.org>
In-Reply-To: <20090413084407.GD23734@psychotron.englab.brq.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Pirko <jpirko@redhat.com>
Date: Mon, 13 Apr 2009 10:44:08 +0200

> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> index a48f5ef..6efc556 100644
> --- a/net/bridge/br_fdb.c
> +++ b/net/bridge/br_fdb.c
 ...
> +static inline int is_dev_addr(struct net_device *dev, unsigned char *addr)
> +{

Please drop the inline, let the compiler work it out.
