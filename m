From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next] net: only check perm protocol when
 register proto
Date: Thu, 17 Sep 2015 21:03:22 -0700 (PDT)
Message-ID: <20150917.210322.516155583143848569.davem@davemloft.net>
References: <20150917.162041.2147817140272126896.davem@davemloft.net>
	<1442548805-5489-1-git-send-email-martinbj2008@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: martinbj2008@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442548805-5489-1-git-send-email-martinbj2008@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: martinbj2008@gmail.com
Date: Fri, 18 Sep 2015 00:00:05 -0400

> From: Junwei Zhang <martinbj2008@gmail.com>
> 
> The permanent protocol nodes are at the head of the list,
> So only need check all these nodes.
> 
> No matter the new node is permanent or not,
> insert the new node after the last permanent protocol node,
> 
> If the new node conflicts with existing permanent node,
> return error.
> 
> Signed-off-by: Martin Zhang <martinbj2008@gmail.com>
> ---
> V2: Fix indentation
>     rewrite statement

Applied, thanks.
