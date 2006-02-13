From: Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>
Subject: Re: [PATCH] [NETFILTER] nf_conntrack: clean up to reduce size of
 'struct nf_conn'
Date: Mon, 13 Feb 2006 10:32:49 +0900 (JST)
Message-ID: <200602130132.k1D1Wo1D003721@toshiba.co.jp>
References: <20060212175622.GG4601@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	davem@davemloft.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: laforge@gnumonks.org
In-Reply-To: <20060212175622.GG4601@sunbeam.de.gnumonks.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


Hi, Harald,

From: Harald Welte <laforge@gnumonks.org>
Date: Sun, 12 Feb 2006 18:56:22 +0100

> [NETFILTER] nf_conntrack: clean up to reduce size of 'struct nf_conn'
> 
> This patch moves all helper related data fields of 'struct nf_conn' into a
> separate structure 'struct nf_conn_help'.  This new structure is only
> present in conntrack entries for which we actually have a helper loaded.
> 
> Also, this patch cleans up the nf_conntrack 'features' mechanism to
> resemble what the original idea was:  Just glue the feature-specific
> data structures at the end of 'struct nf_conn', and explicitly re-calculate
> the pointer to it when needed rather than keeping pointers around.
> 
> Saves 20 bytes per conntrack on my x86_64 box. A non-helped conntrack is
> 276 bytes. We still need to save another 20 bytes in order to fit into to
> target of 256bytes.
> 
> Signed-off-by: Harald Welte <laforge@netfilter.org>

This patch seems not to include fixes I pointed out and you said "fixed".
Please confirm if you really sent the intended one.

Regards,

-- Yasuyuki Kozakai
