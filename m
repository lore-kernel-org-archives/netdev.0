From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cnic: Fix an error handling path in
 'cnic_alloc_bnx2x_resc()'
Date: Sat, 23 Sep 2017 17:04:50 -0700 (PDT)
Message-ID: <20170923.170450.1710391787785987052.davem@davemloft.net>
References: <20170921230111.10135-1-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmaxwell37@gmail.com, stephen@networkplumber.org,
        danielj@mellanox.com, parav@mellanox.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: christophe.jaillet@wanadoo.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170921230111.10135-1-christophe.jaillet@wanadoo.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Date: Fri, 22 Sep 2017 01:01:11 +0200

> All the error handling paths 'goto error', except this one.
> We should also go to error in this case, or some resources will be
> leaking.
> 
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>

Applied, thank you.
