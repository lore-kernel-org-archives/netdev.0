From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [Resend(2)] [PATCH 01/05] ipv6: RFC4214 Support (4)
Date: Tue, 13 Nov 2007 13:10:38 -0800
Message-ID: <20071113131038.50ad9914@freepuppy.rosehill>
References: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC1A@XCH-NW-7V2.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki / =?UTF-8?B?5ZCJ6Jek6Iux?=
	 =?UTF-8?B?5piO?= <yoshfuji@linux-ipv6.org>
To: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:46525 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753663AbXKMVMn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 16:12:43 -0500
In-Reply-To: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC1A@XCH-NW-7V2.nw.nos.boeing.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> +#if defined(CONFIG_IPV6_ISATAP)
> +/* only for IFF_ISATAP interfaces */
> +static inline int ipv6_addr_is_isatap(const struct in6_addr *addr)
> +{
> +       return ((addr->s6_addr32[2] | htonl(0x02000000)) == htonl(0x02005EFE));
> +}
> +#endif
> +

No need to make this conditional, unless you want to define an equivalent
inline for !ISATAP that always returns 0.



-- 
Stephen Hemminger <shemminger@linux-foundation.org>
