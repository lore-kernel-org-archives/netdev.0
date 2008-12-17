From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 1/5] Phonet: allocate a non-Ethernet ARP type
Date: Wed, 17 Dec 2008 21:07:29 +0100
Message-ID: <1229544449.10889.19.camel@violet>
References: <200812171607.14184.remi.denis-courmont@nokia.com>
	 <1229522874-20636-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:58860 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751386AbYLQUHj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 15:07:39 -0500
In-Reply-To: <1229522874-20636-1-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Remi,

> Also leave some room for more 802.11 types.
>=20
> Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.co=
m>
> ---
>  include/linux/if_arp.h |    2 ++
>  net/core/dev.c         |    8 ++++----
>  2 files changed, 6 insertions(+), 4 deletions(-)
>=20
> diff --git a/include/linux/if_arp.h b/include/linux/if_arp.h
> index 4d34018..11df77a 100644
> --- a/include/linux/if_arp.h
> +++ b/include/linux/if_arp.h
> @@ -87,6 +87,8 @@
>  #define ARPHRD_IEEE80211_PRISM 802	/* IEEE 802.11 + Prism2 header  *=
/
>  #define ARPHRD_IEEE80211_RADIOTAP 803	/* IEEE 802.11 + radiotap head=
er */
> =20
> +#define ARPHRD_PHONET	820		/* PhoNet media type		*/
> +
>  #define ARPHRD_VOID	  0xFFFF	/* Void type, nothing is known */
>  #define ARPHRD_NONE	  0xFFFE	/* zero header length */

what kind of communication are you doing over that device. Is it pure I=
P
communication or a PhoNet specific one. In case of pure and simple IP,
then please use the officially assigned Pure IP type from here:

http://www.iana.org/assignments/arp-parameters/arp-parameters.xhtml

Regards

Marcel


