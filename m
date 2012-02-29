From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] ipv6: Fix problem with expired dst cache
Date: Wed, 29 Feb 2012 17:52:16 +0800
Message-ID: <4F4DF550.30009@cn.fujitsu.com>
References: <4F4DEF2F.7010109@cn.fujitsu.com> <1330508743-20005-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52756 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S965223Ab2B2JvX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 04:51:23 -0500
In-Reply-To: <1330508743-20005-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B402=E6=9C=8829=E6=97=A5 17:45, Gao feng =E5=86=99=
=E9=81=93:

> -static struct rt6_info *rt6_alloc_cow(const struct rt6_info *ort,
> +static struct rt6_info *rt6_alloc_cow(struct rt6_info *ort,
>  				      const struct in6_addr *daddr,
>  				      const struct in6_addr *saddr)
>  {
> @@ -934,10 +947,9 @@ struct dst_entry *ip6_blackhole_route(struct net=
 *net, struct dst_entry *dst_ori
>  		rt->rt6i_idev =3D ort->rt6i_idev;
>  		if (rt->rt6i_idev)
>  			in6_dev_hold(rt->rt6i_idev);
> -		rt->dst.expires =3D 0;
> =20
>  		rt->rt6i_gateway =3D ort->rt6i_gateway;
> -		rt->rt6i_flags =3D ort->rt6i_flags & ~RTF_EXPIRES;
> +		rt6_clean_expires(rt);


sorry for this,Please ignore this patch,I will resend it.
