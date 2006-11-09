From: David Miller <davem@davemloft.net>
Subject: Re: [DECnet] Don't clear memory twice.
Date: Wed, 08 Nov 2006 23:02:29 -0800 (PST)
Message-ID: <20061108.230229.109882329.davem@davemloft.net>
References: <20061108154506.GA20057@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, SteveW@ACM.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:50320
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1754356AbWKIHCY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 02:02:24 -0500
To: ralf@linux-mips.org
In-Reply-To: <20061108154506.GA20057@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Wed, 8 Nov 2006 15:45:07 +0000

> When dn_neigh.c was converted from kmalloc to kzalloc in commit
> 0da974f4f303a6842516b764507e3c0a03f41e5a it was missed that
> dn_neigh_seq_open was actually clearing the allocation twice was
> missed.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

Applied, thanks a lot Ralf.
