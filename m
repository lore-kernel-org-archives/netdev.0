From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH] IPV6: note on shared socket options
Date: Thu, 5 Feb 2004 08:25:29 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0402050824170.10943-100000@netcore.fi>
References: <OF2F9C078B.064A8A19-ON87256E30.0077B005-88256E30.0077AF76@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: YOSHIFUJI Hideaki /  =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>,
        <davem@redhat.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OF2F9C078B.064A8A19-ON87256E30.0077B005-88256E30.0077AF76@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 4 Feb 2004, David Stevens wrote:
> Yoshifuji-san,
>       These are defined by draft-ietf-magma-msf-api-03.txt to be in
> netinet/in.h (no place else). What's the advantage of adding another
> copy in in6.h (which currently isn't used by anything)? Portable user apps
> must include netinet/in.h for them, and in-kernel code already does.

FWIW, this is already RFC 3678, so it might make sense to check 
whether there have been changes since the draft version implemented.

> YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>@oss.sgi.com on
> 02/04/2004 03:37:39 AM
> 
> Sent by:    netdev-bounce@oss.sgi.com
> 
> 
> To:    davem@redhat.com
> cc:    yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
> Subject:    [PATCH] IPV6: note on shared socket options
> 
> 
> 
> Hello.
> 
> There're several socket options for multicast
> shared between IPv4 and IPv6.
> Add a note that some range is already used for them.
> 
> (Alternatevely, we could define other names like this:
>  #define IPV6_MCAST_JOIN_GROUP   MCAST_JOIN_GROUP
>  #define IPV6_MCAST_BLOCK_SOURCE MCAST_BLOCK_SOURCE
>  /* bla, bla ... */
> )
> 
> ===== include/linux/in6.h 1.5 vs edited =====
> --- 1.5/include/linux/in6.h   Fri Mar 21 14:23:30 2003
> +++ edited/include/linux/in6.h      Wed Feb  4 20:30:47 2004
> @@ -183,5 +183,17 @@
>  #define IPV6_IPSEC_POLICY    34
>  #define IPV6_XFRM_POLICY     35
> 
> +/*
> + * Multicast:
> + * Following socket options are shared between IPv4 and IPv6.
> + *
> + * MCAST_JOIN_GROUP          42
> + * MCAST_BLOCK_SOURCE        43
> + * MCAST_UNBLOCK_SOURCE            44
> + * MCAST_LEAVE_GROUP         45
> + * MCAST_JOIN_SOURCE_GROUP   46
> + * MCAST_LEAVE_SOURCE_GROUP  47
> + * MCAST_MSFILTER            48
> + */
> 
>  #endif
> 
> --
> Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
> GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
> 

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
