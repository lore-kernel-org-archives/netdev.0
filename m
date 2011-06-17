From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: Remove casts of void *
Date: Thu, 16 Jun 2011 23:23:44 -0400 (EDT)
Message-ID: <20110616.232344.2285390268187937319.davem@davemloft.net>
References: <cover.1308017857.git.joe@perches.com>
	<d010144f11f9165670ac0c9e3559bf5e3191ff28.1308017857.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, sage@newdream.net,
	samuel@sortiz.org, paul.moore@hp.com, vladislav.yasevich@hp.com,
	sri@us.ibm.com, linux-kernel@vger.kernel.org,
	ceph-devel@vger.kernel.org,
	linux-decnet-user@lists.sourceforge.net, linux-sctp@vger.kernel.org
To: joe@perches.com
Return-path: <ceph-devel-owner@vger.kernel.org>
In-Reply-To: <d010144f11f9165670ac0c9e3559bf5e3191ff28.1308017857.git.joe@perches.com>
Sender: ceph-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 13 Jun 2011 19:21:26 -0700

> Unnecessary casts of void * clutter the code.
> 
> These are the remainder casts after several specific
> patches to remove netdev_priv and dev_priv.
> 
> Done via coccinelle script:
> 
> $ cat cast_void_pointer.cocci
> @@
> type T;
> T *pt;
> void *pv;
> @@
> 
> - pt = (T *)pv;
> + pt = pv;
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
