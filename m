From: Daniel Baluta <dbaluta@ixiacom.com>
Subject: Re: [PATCH] libceph: Fix sparse warning
Date: Wed, 22 Aug 2012 12:46:04 +0300
Message-ID: <CAEnQRZBcX7vmaa2rc3-CcCSpayKZca2p11_3eSQaEsj_FAQLNg@mail.gmail.com>
References: <1344950857-32139-1-git-send-email-icurt@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, ceph-devel@vger.kernel.org,
	netdev@vger.kernel.org, Iulius Curt <icurt@ixiacom.com>
To: sage@inktank.com
Return-path: <ceph-devel-owner@vger.kernel.org>
In-Reply-To: <1344950857-32139-1-git-send-email-icurt@ixiacom.com>
Sender: ceph-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 14, 2012 at 4:27 PM, Iulius Curt <iulius.curt@gmail.com> wrote:
> From: Iulius Curt <iulius.curt@gmail.com>
>
> Make ceph_monc_do_poolop() static to remove the following sparse warning:
>  * net/ceph/mon_client.c:616:5: warning: symbol 'ceph_monc_do_poolop' was not
>    declared. Should it be static?
>
> Signed-off-by: Iulius Curt <icurt@ixiacom.com>
> ---
>  net/ceph/mon_client.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/ceph/mon_client.c b/net/ceph/mon_client.c
> index 105d533..3875c60 100644
> --- a/net/ceph/mon_client.c
> +++ b/net/ceph/mon_client.c
> @@ -613,7 +613,7 @@ bad:
>  /*
>   * Do a synchronous pool op.
>   */
> -int ceph_monc_do_poolop(struct ceph_mon_client *monc, u32 op,
> +static int ceph_monc_do_poolop(struct ceph_mon_client *monc, u32 op,
>                         u32 pool, u64 snapid,
>                         char *buf, int len)
>  {
> --
> 1.7.9.5
>
> --

Hi Sage,

Can you have a look on this? :)

thanks,
Daniel.
