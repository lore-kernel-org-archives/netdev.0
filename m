From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] fib_trie: potential out of bounds access in trie_show_stats()
Date: Wed, 24 Jul 2013 17:00:00 +0200
Message-ID: <20130724150000.GB22402@order.stressinduktion.org>
References: <1374519718-8299-1-git-send-email-jerry.snitselaar@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jerry Snitselaar <jerry.snitselaar@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1374519718-8299-1-git-send-email-jerry.snitselaar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 22, 2013 at 12:01:58PM -0700, Jerry Snitselaar wrote:
> With the <= max condition in the for loop, it will be always go 1
> element further than needed. If the condition for the while loop is
> never met, then max is MAX_STAT_DEPTH, and for loop will walk off the
> end of nodesizes[].
> 
> Signed-off-by: Jerry Snitselaar <jerry.snitselaar@oracle.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,

  Hannes
