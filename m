From: "Mike Frysinger" <vapier.adi@gmail.com>
Subject: Re: [PATCH 1/3] Blackfin EMAC Driver: add proper __devinit/__devexit markings
Date: Sun, 27 Jul 2008 09:03:27 -0400
Message-ID: <8bd0f97a0807270603s2d3ac6f7q3735b2ac6e31a22c@mail.gmail.com>
References: <1217139235-19018-1-git-send-email-cooloney@kernel.org>
	 <1217139235-19018-2-git-send-email-cooloney@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org
To: "Bryan Wu" <cooloney@kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757214AbYG0NDl@vger.kernel.org>
In-Reply-To: <1217139235-19018-2-git-send-email-cooloney@kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 27, 2008 at 2:13 AM, Bryan Wu wrote:
> From: Mike Frysinger <vapier.adi@gmail.com>
>
> Signed-off-by: Mike Frysinger <vapier.adi@gmail.com>
> Signed-off-by: Bryan Wu <cooloney@kernel.org>
> ---
>  drivers/net/bfin_mac.c |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
> index 4144343..e18a7ee 100644
> --- a/drivers/net/bfin_mac.c
> +++ b/drivers/net/bfin_mac.c
> @@ -614,7 +614,7 @@ static int bfin_mac_hard_start_xmit(struct sk_buff *skb,
>         * Is skb->data always 16-bit aligned?
>         * Do we need to memcpy((char *)(tail->packet + 2), skb->data, len)?
>         */
> -       if ((((unsigned int)(skb->data)) & 0x02) == 2) {
> +       if ((((unsigned int)(skb->data)) & 0x01) == 0) {
>                /* move skb->data to current_tx_ptr payload */
>                data = (unsigned int)(skb->data) - 2;
>                *((unsigned short *)data) = (unsigned short)(skb->len);

i think this unrelated hunk slipped in
-mike
