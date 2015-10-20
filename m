From: Samuel Ortiz <sameo@linux.intel.com>
Subject: Re: [PATCH 1/2] NFC: delete null dereference
Date: Tue, 20 Oct 2015 06:50:58 +0200
Message-ID: <20151020045058.GG9764@zurbaran.home>
References: <1445074340-21955-1-git-send-email-Julia.Lawall@lip6.fr>
 <1445074340-21955-2-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	kernel-janitors@vger.kernel.org,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia Lawall <Julia.Lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1445074340-21955-2-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Julia,

On Sat, Oct 17, 2015 at 11:32:19AM +0200, Julia Lawall wrote:
> The exit label performs device_unlock(&dev->dev);, which will fail when dev
> is NULL, and nfc_put_device(dev);, which is not useful when dev is NULL, so
> just exit the function immediately.
> 
> Problem found using scripts/coccinelle/null/deref_null.cocci
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> ---
>  net/nfc/netlink.c |    6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
Applied to nfc-next, thanks.

Cheers,
Samuel.
