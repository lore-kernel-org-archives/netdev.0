From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip: fix error handling in ip_finish_output2()
Date: Mon, 06 Aug 2012 13:32:18 -0700 (PDT)
Message-ID: <20120806.133218.784665611397147880.davem@davemloft.net>
References: <20120806135529.GA30699@albatros>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: segoon@openwall.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120806135529.GA30699@albatros>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vasily Kulikov <segoon@openwall.com>
Date: Mon, 6 Aug 2012 17:55:29 +0400

> __neigh_create() returns either a pointer to struct neighbour or PTR_ERR().
> But the caller expects it to return either a pointer or NULL.  Replace
> the NULL check with IS_ERR() check.
> 
> The bug was introduced in a263b3093641fb1ec377582c90986a7fd0625184.
> 
> Signed-off-by: Vasily Kulikov <segoon@openwall.com>

Applied.

Please provide the proper commit log header line text when referencing
another commit, otherwise in trees where the SHA1 IDs are different,
nobody will be able to figure out what you are trying to refer to.

Thanks.
