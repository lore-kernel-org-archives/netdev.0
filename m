From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 2.6.19-rc2] [REVISED] net/ipv4/multipath_wrandom.c: check
 kmalloc() return value.
Date: Mon, 23 Oct 2006 03:46:28 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0610230341080.16474@d.namei>
References: <20061022235958.b31d7529.amit2030@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, akpm@osdl.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:45545 "EHLO
	mail8.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751701AbWJWHqa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Oct 2006 03:46:30 -0400
To: Amit Choudhary <amit2030@gmail.com>
In-Reply-To: <20061022235958.b31d7529.amit2030@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 22 Oct 2006, Amit Choudhary wrote:

> Description: Check the return value of kmalloc() in function wrandom_set_nhinfo(), in file net/ipv4/multipath_wrandom.c.
> 
> Signed-off-by: Amit Choudhary <amit2030@gmail.com>

Acked-by: James Morris <jmorris@namei.org>

> @@ -242,6 +242,9 @@ static void wrandom_set_nhinfo(__be32 ne
>  		target_route = (struct multipath_route *)
>  			kmalloc(size_rt, GFP_ATOMIC);

It'd be nice to see these casts removed in a future cleanup.



- James
-- 
James Morris
<jmorris@namei.org>
