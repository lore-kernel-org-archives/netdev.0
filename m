From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6] 2/2:  Fix NAT helper locking
Date: Fri, 3 Sep 2004 00:24:53 -0700
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <20040903002453.77beee16.davem@davemloft.net>
References: <20040903070234.GQ26263@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20040903070234.GQ26263@sunbeam.de.gnumonks.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Fri, 3 Sep 2004 09:02:34 +0200
Harald Welte <laforge@netfilter.org> wrote:

> This is the second of a two part patch.
> 
> This part fixes the locking in NAT helpers.
> 
> Please apply, Thanks.

Applied both patches, but the first had serious offsets
and the second had to be applied by hand due to rejects
against the current 2.6.x sources.

Ummm... wow what ancient tree did you patch against
Harald?  The tree you patched against didn't even have the
skb_header_pointer() changes in it, that's caveman
era :-)  That's what caused the rejects.

Anyways, I merged it all in cleanly.

Thanks.
