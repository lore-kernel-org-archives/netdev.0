From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] vhost: Storage class should be before const qualifier
Date: Mon, 17 May 2010 16:13:35 +0300
Message-ID: <20100517131335.GA12126@redhat.com>
References: <1274101969-21109-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1274101969-21109-1-git-send-email-tklauser@distanz.ch>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 17, 2010 at 03:12:49PM +0200, Tobias Klauser wrote:
> The C99 specification states in section 6.11.5:
> 
> The placement of a storage-class specifier other than at the beginning
> of the declaration specifiers in a declaration is an obsolescent
> feature.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>


Will apply, thanks!
Just to clarify: does some compiler/checker actually barf on this?

> ---
>  drivers/vhost/net.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index aa88911..cd36f5f 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -626,7 +626,7 @@ static long vhost_net_compat_ioctl(struct file *f, unsigned int ioctl,
>  }
>  #endif
>  
> -const static struct file_operations vhost_net_fops = {
> +static const struct file_operations vhost_net_fops = {
>  	.owner          = THIS_MODULE,
>  	.release        = vhost_net_release,
>  	.unlocked_ioctl = vhost_net_ioctl,
> -- 
> 1.6.3.3
