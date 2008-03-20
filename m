From: "Will Newton" <will.newton-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH/RFC] introduce ARCH_CAN_UNALIGNED_ACCESS Kconfig symbol
Date: Thu, 20 Mar 2008 14:39:08 +0000
Message-ID: <87a5b0800803200739v6d222afck850f221eae1edd70@mail.gmail.com>
References: <1206023695.16475.137.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Daniel Drake" <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
	"Linux Kernel list" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Johannes Berg" <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1206023695.16475.137.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 20, 2008 at 2:34 PM, Johannes Berg
<johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:

>  +For some ethernet hardware that cannot DMA to unaligned addresses like
>  +4*n+2 or non-ethernet hardware, this can be a problem, and it is then
>  +required to copy the incoming frame into an aligned buffer. Because this is
>  +unnecessary on architectures that can do unaligned accesses, the code can be
>  +made depend on CONFIG_ARCH_CAN_UNALIGNED_ACCESS like so:
>  +
>  +#ifdef CONFIG_ARCH_CAN_UNALIGNED_ACCESS
>  +       skb = copy skb
>  +#else
>  +       skb = original skb
>  +#endif

Is this logic reversed?
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
