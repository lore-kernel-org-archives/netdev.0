From: Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next v9 8/9] net: openvswitch - set name
	assign type
Date: Thu, 17 Jul 2014 11:22:22 -0700
Message-ID: <CALnjE+pK7bT=EmRT-zeL7thUUqgu-a66kwPK+7TT4cgKqjT1VA@mail.gmail.com>
References: <1405584370-30054-1-git-send-email-teg@jklm.no>
 <1405584370-30054-9-git-send-email-teg@jklm.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
 LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Tom Gundersen <teg-B22kvLQNl6c@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1405584370-30054-9-git-send-email-teg-B22kvLQNl6c@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Thu, Jul 17, 2014 at 1:06 AM, Tom Gundersen <teg-B22kvLQNl6c@public.gmane.org> wrote:
> Signed-off-by: Tom Gundersen <teg-B22kvLQNl6c@public.gmane.org>
> Cc: Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
> Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Looks good.

Acked-by: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>

> ---
>
> v9: set NET_NAME_USER directly in internal_dev_create as requested by Pravin Shelar
>
>  net/openvswitch/vport-internal_dev.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
> index bd65855..2741285 100644
> --- a/net/openvswitch/vport-internal_dev.c
> +++ b/net/openvswitch/vport-internal_dev.c
> @@ -165,7 +165,7 @@ static struct vport *internal_dev_create(const struct vport_parms *parms)
>         netdev_vport = netdev_vport_priv(vport);
>
>         netdev_vport->dev = alloc_netdev(sizeof(struct internal_dev),
> -                                        parms->name, NET_NAME_UNKNOWN,
> +                                        parms->name, NET_NAME_USER,
>                                          do_setup);
>         if (!netdev_vport->dev) {
>                 err = -ENOMEM;
> --
> 1.9.3
>
