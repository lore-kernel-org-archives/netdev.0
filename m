From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 04/16] tipc: rename struct
 tipc_skb_cb member handle to bytes_read
Date: Sat, 29 Oct 2016 17:01:20 -0400 (EDT)
Message-ID: <20161029.170120.1383330491683606210.davem@davemloft.net>
References: <1477578157-13256-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
	<1477578157-13256-5-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: parthasarathy.bhuvaragan@ericsson.com
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1477578157-13256-5-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Date: Thu, 27 Oct 2016 16:22:25 +0200

> @@ -95,7 +95,7 @@ struct plist;
>  #define TIPC_MEDIA_INFO_OFFSET	5
>  
>  struct tipc_skb_cb {
> -	void *handle;
> +	u32 bytes_read;
>  	struct sk_buff *tail;
>  	bool validated;
>  	bool wakeup_pending;

If this is now a u32, then:

> -		u32 offset = (u32)(unsigned long)(TIPC_SKB_CB(buf)->handle);
> +		u32 offset = (u32)(TIPC_SKB_CB(buf)->bytes_read);

This cast is unnecessary as are the parenthesis.

------------------------------------------------------------------------------
The Command Line: Reinvented for Modern Developers
Did the resurgence of CLI tooling catch you by surprise?
Reconnect with the command line and become more productive. 
Learn the new .NET and ASP.NET CLI. Get your free copy!
http://sdm.link/telerik
