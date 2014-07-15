From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH v7 29/33] net: brcmfmac - set name assign type
Date: Tue, 15 Jul 2014 15:39:26 -0400
Message-ID: <20140715193926.GF26012@tuxdriver.com>
References: <1404980258-30853-1-git-send-email-teg@jklm.no>
 <1404980258-30853-30-git-send-email-teg@jklm.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>,
	Kay Sievers <kay@vrfy.org>,
	Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com
To: Tom Gundersen <teg@jklm.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1404980258-30853-30-git-send-email-teg@jklm.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I don't seem to have a line with "NET_NAME_UNKNOWN" in this driver
in any of my kernel trees.  What tree are you using for development?

On Thu, Jul 10, 2014 at 10:17:34AM +0200, Tom Gundersen wrote:
> The name is given by the firmware, so we assume it is predictable.
> 
> Signed-off-by: Tom Gundersen <teg@jklm.no>
> Cc: Brett Rudley <brudley@broadcom.com>
> Cc: Arend van Spriel <arend@broadcom.com>
> Cc: "Franky (Zhenhui) Lin" <frankyl@broadcom.com>
> Cc: Hante Meuleman <meuleman@broadcom.com>
> Cc: John Linville <linville@tuxdriver.com>
> Cc: linux-wireless@vger.kernel.org
> Cc: brcm80211-dev-list@broadcom.com
> ---
>  drivers/net/wireless/brcm80211/brcmfmac/fweh.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/fweh.c b/drivers/net/wireless/brcm80211/brcmfmac/fweh.c
> index f6990f2..8d32721 100644
> --- a/drivers/net/wireless/brcm80211/brcmfmac/fweh.c
> +++ b/drivers/net/wireless/brcm80211/brcmfmac/fweh.c
> @@ -201,7 +201,8 @@ static void brcmf_fweh_handle_if_event(struct brcmf_pub *drvr,
>  		brcmf_dbg(EVENT, "adding %s (%pM)\n", emsg->ifname,
>  			  emsg->addr);
>  		ifp = brcmf_add_if(drvr, ifevent->bssidx, ifevent->ifidx,
> -				   emsg->ifname, NET_NAME_UNKNOWN, emsg->addr);
> +				   emsg->ifname, NET_NAME_PREDICTABLE,
> +				   emsg->addr);
>  		if (IS_ERR(ifp))
>  			return;
>  		brcmf_fws_add_interface(ifp);
> -- 
> 1.9.3
> 
> 

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
