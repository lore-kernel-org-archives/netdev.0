From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] xfrm: take iphdr size into account for esp payload
 size calculation
Date: Mon, 14 May 2012 18:39:52 -0400 (EDT)
Message-ID: <20120514.183952.1459413342269893446.davem@davemloft.net>
References: <20120511010249.GA23584@d2.synalogic.ca>
	<1336698442-25148-1-git-send-email-bpoirier@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	linux-kernel@vger.kernel.org
To: bpoirier@suse.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1336698442-25148-1-git-send-email-bpoirier@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Poirier <bpoirier@suse.de>
Date: Thu, 10 May 2012 21:07:22 -0400

> -	return mtu - 2;
> +	return ((mtu - x->props.header_len - crypto_aead_authsize(esp->aead) -
> +			l3_adj) & ~(align - 1)) + (l3_adj - 2);
>  }

The formatting of this expression is completely wrong, you need
to make the "l3_adj" in the second line be aligned with the openning
parenthesis on the previous line at a depth determined based upon
how deeply in the openning parenthesis context this expression sits.

Just using TABS is ugly, and not allowed.

Use something like emacs's "C mode" with Linux coding style enabled
to assist you if you can't figure it out yourself.
