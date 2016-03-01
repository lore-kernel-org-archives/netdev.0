From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Subject: Re: [PATCH RFC 1/2] rhashtable: accept GFP flags in
 rhashtable_walk_init
Date: Tue, 1 Mar 2016 20:31:34 +0100
Message-ID: <20160301193134.GA11309@pox.localdomain>
References: <1456708013-19590-1-git-send-email-me@bobcopeland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bob Copeland <me-aXfl/3sk2vNUbtYUoyoikg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1456708013-19590-1-git-send-email-me-aXfl/3sk2vNUbtYUoyoikg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 02/28/16 at 08:06pm, Bob Copeland wrote:
> In certain cases, the 802.11 mesh pathtable code wants to
> iterate over all of the entries in the forwarding table from
> the receive path, which is inside an RCU read-side critical
> section.  Enable walks inside atomic sections by allowing
> GFP_ATOMIC allocations for the walker state.
> 
> Change all existing callsites to pass in GFP_KERNEL.
> 
> Cc: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Signed-off-by: Bob Copeland <me-aXfl/3sk2vNUbtYUoyoikg@public.gmane.org>

rhashtable bits LGTM

Acked-by: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
