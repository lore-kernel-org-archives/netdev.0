From: "David S. Miller" <davem@davemloft.net>
Subject: Re: proto_unregister sleeps while atomic
Date: Tue, 06 Sep 2005 19:48:05 -0700 (PDT)
Message-ID: <20050906.194805.111546627.davem@davemloft.net>
References: <431E1FE9.7030405@trash.net>
	<20050906.160728.25203864.davem@davemloft.net>
	<431E2978.2030701@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniele@orlandi.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750819AbVIGCsI@vger.kernel.org>
To: kaber@trash.net
In-Reply-To: <431E2978.2030701@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 07 Sep 2005 01:42:48 +0200

> The only other user of proto_list besides proto_register, which
> doesn't care, are the seqfs functions. They use the slab pointer,
> but in a harmless way:
> 
>                     proto->slab == NULL ? "no" : "yes",
> 
> Anyway, I've moved it up to the top.

Ok thanks, patch applied.
