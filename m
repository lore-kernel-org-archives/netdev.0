From: Lars Ellenberg <lars.ellenberg-63ez5xqkn6DQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next v3] block/drbd: align properly u64
	in nl messages
Date: Mon, 9 May 2016 15:15:48 +0200
Message-ID: <20160509131547.GX16459@soda.linbit>
References: <20160503100644.GE16459@soda.linbit>
	<1462786820-15519-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, drbd-dev-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, philipp.reisner-63ez5xqkn6DQT0dZR+AlfA@public.gmane.org
To: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Return-path: <drbd-dev-bounces-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1462786820-15519-1-git-send-email-nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <http://lists.linbit.com/mailman/options/drbd-dev>,
	<mailto:drbd-dev-request-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linbit.com/pipermail/drbd-dev>
List-Post: <mailto:drbd-dev-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org>
List-Help: <mailto:drbd-dev-request-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org?subject=help>
List-Subscribe: <http://lists.linbit.com/mailman/listinfo/drbd-dev>,
	<mailto:drbd-dev-request-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org?subject=subscribe>
Sender: drbd-dev-bounces-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org
Errors-To: drbd-dev-bounces-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, May 09, 2016 at 11:40:20AM +0200, Nicolas Dichtel wrote:
> The attribute 0 is never used in drbd, so let's use it as pad attribute
> in netlink messages. This minimizes the patch.
> 
> Note that this patch is only compile-tested.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Lars Ellenberg <lars.ellenberg-63ez5xqkn6DQT0dZR+AlfA@public.gmane.org>
> ---
> 
> v2 -> v3:
>   use 0 as padattr instead of adding new attributes

Thanks.

> v1 -> v2:
>  rework the patch to handle all cases
> 
> Maybe prefixing genl_magic_func.h and genl_magic_struct.h by 'drbd_'
> could be interesting so that new module won't use it. What is your
> opinion?

This was supposed to not be DRBD specific.  But it might even still
need some massaging before it was truly generic. And obviously,
it does not meet the taste of genetlink folks, to say the least :(

I don't care either way.

    Lars Ellenberg
