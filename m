From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] tg3.h & b44.h ifndef ADVERTISE_PAUSE typo
Date: Tue, 11 Jan 2005 13:57:44 -0500
Message-ID: <41E421A8.60203@pobox.com>
References: <1105454553.4264.4.camel@dhollis-lnx.centricconsulting.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: David Hollis <dhollis@davehollis.com>
In-Reply-To: <1105454553.4264.4.camel@dhollis-lnx.centricconsulting.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David Hollis wrote:
> tg3.h and b44.h define ADVERTISE_PAUSE_CAP if ADVERTISE_PAUSE
> is not defined.  Both include a notation that these values should
> be added to mii.h.  If ADVERTISE_PAUSE_CAP was added to mii.h,
> these defines would break since they are checking for ADVERTISE_PAUSE
> instead of ADVERTISE_PAUSE_CAP.
> 
> Signed-off-by: David Hollis <dhollis@davehollis.com>
> 
>  drivers/net/b44.h |    2 +-
>  drivers/net/tg3.h |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> --- a/drivers/net/b44.h	2005-01-11 09:34:39.178739728 -0500
> +++ b/drivers/net/b44.h	2005-01-11 09:34:54.215453800 -0500
> @@ -303,7 +303,7 @@
>  #define  MII_TLEDCTRL_ENABLE	0x0040
>  
>  /* XXX Add this to mii.h */
> -#ifndef ADVERTISE_PAUSE
> +#ifndef ADVERTISE_PAUSE_CAP
>  #define ADVERTISE_PAUSE_CAP		0x0400
>  #endif
>  #ifndef ADVERTISE_PAUSE_ASYM
> --- a/drivers/net/tg3.h	2005-01-11 09:34:43.562073360 -0500
> +++ b/drivers/net/tg3.h	2005-01-11 09:35:00.786454856 -0500
> @@ -1532,7 +1532,7 @@
>  #define MII_TG3_INT_ANEG_PAGE_RX	0x0400
>  
>  /* XXX Add this to mii.h */
> -#ifndef ADVERTISE_PAUSE
> +#ifndef ADVERTISE_PAUSE_CAP
>  #define ADVERTISE_PAUSE_CAP		0x0400
>  #endif
>  #ifndef ADVERTISE_PAUSE_ASYM

Just kill the ifdef and add it to mii.h.

	Jeff
