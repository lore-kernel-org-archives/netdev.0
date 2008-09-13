From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH davem-next 1/1] r8169: select MII in Kconfig
Date: Sat, 13 Sep 2008 15:35:27 -0400
Message-ID: <48CC15FF.40608@garzik.org>
References: <20080913130438.GA8375@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Hugh Dickins <hugh@veritas.com>,
	Jiri Slaby <jirislaby@gmail.com>,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ivan Vecera <ivecera@redhat.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39073 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752617AbYIMTfc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 15:35:32 -0400
In-Reply-To: <20080913130438.GA8375@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu wrote:
> drivers/built-in.o: In function `rtl8169_gset_xmii':
> r8169.c:(.text+0x82259): undefined reference to `mii_ethtool_gset'
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>
> Acked-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Edward Hsu <edward_hsu@realtek.com.tw>
> ---
>  drivers/net/Kconfig |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 4a11296..60a0453 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -2046,6 +2046,7 @@ config R8169
>  	tristate "Realtek 8169 gigabit ethernet support"
>  	depends on PCI
>  	select CRC32
> +	select MII
>  	---help---

applied


