From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: linux-next: manual merge of the devicetree tree with the net-next
 tree
Date: Thu, 13 Feb 2014 19:47:58 -0800
Message-ID: <52FD91EE.4010403@gmail.com>
References: <20140214141639.74ea45728f39a8ee874ce986@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	Grant Likely <grant.likely@secretlab.ca>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140214141639.74ea45728f39a8ee874ce986@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

Le 13/02/2014 19:16, Stephen Rothwell a =E9crit :
> Hi Grant,
>
> Today's linux-next merge of the devicetree tree got a conflict in
> drivers/of/of_net.c between commit 8a2fe56e8827 ("net: phy: re-design
> phy_modes to be self-contained") from the net-next tree and commit
> cf4c9eb5a451 ("of: make of_get_phy_mode parse 'phy-connection-type'")
> from the devicetree tree.
>
> I fixed it up (I applied the following merge fix patch) and can carry=
 the
> fix as necessary (no action is required).

Looks good to me, thanks for fixing that!

>
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Fri, 14 Feb 2014 14:14:31 +1100
> Subject: [PATCH] net: of: merges fix for a moved comment
>
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> ---
>   include/linux/phy.h | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/include/linux/phy.h b/include/linux/phy.h
> index 42f1bc7eaeb0..bc77c174e0a3 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -79,8 +79,8 @@ typedef enum {
>
>   /**
>    * It maps 'enum phy_interface_t' found in include/linux/phy.h
> - * into the device tree binding of 'phy-mode', so that Ethernet
> - * device driver can get phy interface from device tree.
> + * into the device tree binding of 'phy-mode' or 'phy-connection-typ=
e',
> + * so that Ethernet device driver can get phy interface from device =
tree.
>    */
>   static inline const char *phy_modes(phy_interface_t interface)
>   {
>
