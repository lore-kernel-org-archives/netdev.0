From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] iptables: Fix warning in CONNMARK
Date: Sun, 24 Oct 2004 16:17:34 +0200
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <417BB97E.2000706@trash.net>
References: <20041024135721.GO21977@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: laforge@netfilter.org, netdev@oss.sgi.com,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	hno@marasystems.com
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041024135721.GO21977@postel.suug.ch>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Applied, thanks.

Thomas Graf wrote:

>Signed-off-by: Thomas Graf <tgraf@suug.ch>
>
>--- linux-2.6.10-rc1-bk1.orig/net/ipv4/netfilter/ipt_CONNMARK.c	2004-10-24 10:58:49.000000000 +0200
>+++ linux-2.6.10-rc1-bk1/net/ipv4/netfilter/ipt_CONNMARK.c	2004-10-24 15:35:18.000000000 +0200
>@@ -60,7 +60,7 @@
> 		break;
> 	    case IPT_CONNMARK_RESTORE:
> 		nfmark = (*pskb)->nfmark;
>-		diff = (ct->mark ^ nfmark & markinfo->mask);
>+		diff = ((ct->mark ^ nfmark) & markinfo->mask);
> 		if (diff != 0) {
> 		    (*pskb)->nfmark = nfmark ^ diff;
> 		    (*pskb)->nfcache |= NFC_ALTERED;
>
>  
>
