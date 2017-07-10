From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH iproute2] ip: change flag names to an array
Date: Mon, 10 Jul 2017 10:10:56 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD0036A4F@AcuExch.aculab.com>
References: <20170707153941.5427-1-stephen@networkplumber.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "lorenzo@google.com" <lorenzo@google.com>
To: 'Stephen Hemminger' <stephen@networkplumber.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.184]:59399 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753222AbdGJKLI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2017 06:11:08 -0400
In-Reply-To: <20170707153941.5427-1-stephen@networkplumber.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From:  Stephen Hemminger
> Sent: 07 July 2017 16:40
> For the most of the address flags, use a table of bit values rather
> than open coding every value.  This allows for easier inevitable
> expansion of flags.
> 
> This also fixes the missing stable-privacy flag.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> ---
>  ip/ipaddress.c | 152 ++++++++++++++++++++++++---------------------------------
>  1 file changed, 65 insertions(+), 87 deletions(-)
> 
> diff --git a/ip/ipaddress.c b/ip/ipaddress.c
> index f06f5829fb61..b4efb9fedcd2 100644
> --- a/ip/ipaddress.c
> +++ b/ip/ipaddress.c
> @@ -1013,14 +1013,67 @@ static unsigned int get_ifa_flags(struct ifaddrmsg *ifa,
>  				ifa->ifa_flags;
>  }
> 
> +
> +static const char *ifa_flag_names[] = {
> +	"secondary",
> +	"nodad",
> +	"optimistic",
> +	"dadfailed",
> +	"home",
> +	"deprecated",
> +	"tentative",
> +	"permanent",
> +	"mngtmpaddr",
> +	"noprefixroute",
> +	"autojoin",
> +	"stable-privacy",
> +};

It would be safer to set up a table of the constant - string pairs
instead of relying on the table being in the right order.

	David
