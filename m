From: Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 6/8] trivial: fix typo s/refference/reference/ in
 comment
Date: Fri, 16 Oct 2009 15:25:12 +0200 (CEST)
Message-ID: <alpine.LSU.2.00.0910161524480.8582@wotan.suse.de>
References: <1255637783-6109-1-git-send-email-cascardo@holoscopio.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>,
	Wang Chen <wangchen-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Thadeu Lima de Souza Cascardo <cascardo-DmMZpsCg3uxeGPcbtGPokg@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1255637783-6109-1-git-send-email-cascardo-DmMZpsCg3uxeGPcbtGPokg@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 15 Oct 2009, Thadeu Lima de Souza Cascardo wrote:

> diff --git a/net/bluetooth/bnep/core.c b/net/bluetooth/bnep/core.c
> index cafe9f5..1bd9398 100644
> --- a/net/bluetooth/bnep/core.c
> +++ b/net/bluetooth/bnep/core.c
> @@ -78,7 +78,7 @@ static struct bnep_session *__bnep_get_session(u8 *dst)
>  static void __bnep_link_session(struct bnep_session *s)
>  {
>  	/* It's safe to call __module_get() here because sessions are added
> -	   by the socket layer which has to hold the refference to this module.
> +	   by the socket layer which has to hold the reference to this module.
>  	 */
>  	__module_get(THIS_MODULE);
>  	list_add(&s->list, &bnep_session_list);

Merged together with patches 2-8 from your series and applied to trivial
queue.

-- 
Jiri Kosina
SUSE Labs, Novell Inc.
