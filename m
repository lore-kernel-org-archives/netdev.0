From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 3/14] drivers/vhost/vhost.c: delete double assignment
Date: Tue, 26 Oct 2010 13:06:44 +0200
Message-ID: <20101026110644.GA7922@redhat.com>
References: <1288088743-3725-1-git-send-email-julia@diku.dk>
	<1288088743-3725-4-git-send-email-julia@diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: virtualization@lists.osdl.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
        netdev@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1288088743-3725-4-git-send-email-julia@diku.dk>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 26, 2010 at 12:25:32PM +0200, Julia Lawall wrote:
> From: Julia Lawall <julia@diku.dk>
> 
> Delete successive assignments to the same location.
> 
> A simplified version of the semantic match that finds this problem is as
> follows: (http://coccinelle.lip6.fr/)
> 
> // <smpl>
> @@
> expression i;
> @@
> 
> *i = ...;
>  i = ...;
> // </smpl>
> 
> Signed-off-by: Julia Lawall <julia@diku.dk>

Thanks, applied.

> ---
>  drivers/vhost/vhost.c |    1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index 94701ff..ed27727 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -157,7 +157,6 @@ static void vhost_vq_reset(struct vhost_dev *dev,
>  	vq->avail_idx = 0;
>  	vq->last_used_idx = 0;
>  	vq->used_flags = 0;
> -	vq->used_flags = 0;
>  	vq->log_used = false;
>  	vq->log_addr = -1ull;
>  	vq->vhost_hlen = 0;
