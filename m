From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qed: remove unnecessary call to memset
Date: Fri, 15 Sep 2017 14:02:19 -0700 (PDT)
Message-ID: <20170915.140219.188567213297726189.davem@davemloft.net>
References: <1505215162-3917-1-git-send-email-himanshujha199640@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@cavium.com, Ariel.Elior@cavium.com,
        everest-linux-l2@cavium.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: himanshujha199640@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505215162-3917-1-git-send-email-himanshujha199640@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Himanshu Jha <himanshujha199640@gmail.com>
Date: Tue, 12 Sep 2017 16:49:22 +0530

> call to memset to assign 0 value immediately after allocating
> memory with kzalloc is unnecesaary as kzalloc allocates the memory
> filled with 0 value.
> 
> Semantic patch used to resolve this issue:
> 
> @@
> expression e,e2; constant c;
> statement S;
> @@
> 
>   e = kzalloc(e2, c);
>   if(e == NULL) S
> - memset(e, 0, e2);
> 
> Signed-off-by: Himanshu Jha <himanshujha199640@gmail.com>

Applied.
