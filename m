From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC PATCH] net, tun: remove the flow cache
Date: Mon, 16 Dec 2013 23:47:36 -0800
Message-ID: <20131216234736.781457cd@samsung-9.home.lan>
References: <1387265182-27312-1-git-send-email-zwu.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, mst@redhat.com, jasowang@redhat.com,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: Zhi Yong Wu <zwu.kernel@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1387265182-27312-1-git-send-email-zwu.kernel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 17 Dec 2013 15:26:22 +0800
Zhi Yong Wu <zwu.kernel@gmail.com> wrote:

> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
> 
> The flow cache is an extremely broken concept, and it usually brings up
> growth issues and DoS attacks, so this patch is trying to remove it from
> the tuntap driver, and insteadly use a simpler way for its flow control.
> 
> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
> ---
>  drivers/net/tun.c |  208 +++--------------------------------------------------
>  1 files changed, 10 insertions(+), 198 deletions(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 7c8343a..7c27fdc 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -32,12 +32,15 @@
>   *
>   *  Daniel Podlejski <underley@underley.eu.org>
>   *    Modifications for 2.3.99-pre5 kernel.
> + *
> + *  Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
> + *    Remove the flow cache.
>   */

I agree with your patch, but please don't add to the comment changelog.
These are all historical. The kernel development process has not used
them for 5+ years.

Can we get kernel janitors to just remove them, or would that step
on too many early developers toes by removing credit?
