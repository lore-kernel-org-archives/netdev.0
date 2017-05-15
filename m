From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 1/3] Fix ERROR: trailing statements should be on next line
Date: Mon, 15 May 2017 05:58:05 +0300
Message-ID: <20170515055700-mutt-send-email-mst@kernel.org>
References: <20170514175130.18664-1-macfij7@wp.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Maciek Fijalkowski <macfij7@wp.pl>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20170514175130.18664-1-macfij7@wp.pl>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Sun, May 14, 2017 at 07:51:28PM +0200, Maciek Fijalkowski wrote:
> From: Maciej Fijalkowski <macfij7@wp.pl>
> 
> Signed-off-by: Maciej Fijalkowski <macfij7@wp.pl>

I prefer the original form - ; isn't a full statement.

> ---
>  drivers/net/virtio_net.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 9320d96..f20dfb8 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -217,7 +217,8 @@ static void give_pages(struct receive_queue *rq, struct page *page)
>  	struct page *end;
>  
>  	/* Find end of list, sew whole thing into vi->rq.pages. */
> -	for (end = page; end->private; end = (struct page *)end->private);
> +	for (end = page; end->private; end = (struct page *)end->private)
> +		;
>  	end->private = (unsigned long)rq->pages;
>  	rq->pages = page;
>  }
> -- 
> 2.4.11
