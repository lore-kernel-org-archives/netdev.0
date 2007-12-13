From: Alexey Dobriyan <adobriyan-3ImXcnM4P+0@public.gmane.org>
Subject: Re: [Devel] [PATCH 2.6.25] [IPV4] Reduce whitespaces in fib_rules.h.
Date: Thu, 13 Dec 2007 17:47:07 +0300
Message-ID: <20071213144707.GB6209@localhost.sw.ru>
References: <20071213141842.GA9939@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20071213141842.GA9939-aPCOdVxUTlgvJsYlp49lxw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 13, 2007 at 05:18:42PM +0300, Denis V. Lunev wrote:
> There are to many spaces between type and function name in the declaration
> of fib rules manipulation routines. Eat them and save a couple of lines.

If this patch is going in, it would be nice to get rid of "extern" as
well.

	Alexey, who once removed all externs from prototypes
	        and got 4 seconds compilation speedup.

> --- a/include/net/fib_rules.h
> +++ b/include/net/fib_rules.h
> @@ -101,14 +101,12 @@ static inline u32 frh_get_table(struct fib_rule_hdr *frh, struct nlattr **nla)
>  	return frh->table;
>  }
>  
> -extern int			fib_rules_register(struct fib_rules_ops *);
> -extern int			fib_rules_unregister(struct fib_rules_ops *);
> -extern void                     fib_rules_cleanup_ops(struct fib_rules_ops *);
> +extern int fib_rules_register(struct fib_rules_ops *);
> +extern int fib_rules_unregister(struct fib_rules_ops *);
> +extern void fib_rules_cleanup_ops(struct fib_rules_ops *);
>  
> -extern int			fib_rules_lookup(struct fib_rules_ops *,
> -						 struct flowi *, int flags,
> -						 struct fib_lookup_arg *);
> -extern int			fib_default_rule_add(struct fib_rules_ops *,
> -						     u32 pref, u32 table,
> -						     u32 flags);
> +extern int fib_rules_lookup(struct fib_rules_ops *, struct flowi *, int flags,
> +			    struct fib_lookup_arg *);
> +extern int fib_default_rule_add(struct fib_rules_ops *, u32 pref, u32 table,
> +				u32 flags);
>  #endif
