From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: kernel 2.6.25-rc7 highly unstable on high load
Date: Thu, 27 Mar 2008 17:07:29 +0100
Message-ID: <47EBC641.8040405@cosmosbay.com>
References: <20080327062502.M51594@visp.net.lb> <20080326.234049.256533912.davem@davemloft.net> <47EB46BD.2080001@cosmosbay.com> <20080327144102.M65267@visp.net.lb> <47EBB4A3.4090102@cosmosbay.com> <20080327151520.M89250@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kaber@trash.net, netfilter-devel@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2e.orange.fr ([80.12.242.112]:25095 "EHLO smtp2e.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756464AbYC0QHg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 12:07:36 -0400
In-Reply-To: <20080327151520.M89250@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko a =C3=A9crit :
> I did this tuning. Not sure what does mean rt_cache_entries, but seem=
s they=20
> are still increasing.
>
> Kup /config #  rtstat -c1000 -i60
> rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cac=
he|
> rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cac=
he|
> rt_cache|
>  entries|  in_hit|in_slow_|in_slow_|in_no_ro|  in_brd|in_marti|in_mar=
ti|=20
> out_hit|out_slow|out_slow|gc_total|gc_ignor|gc_goal_|gc_dst_o|in_hlis=
t|
> out_hlis|
>         |        |     tot|      mc|     ute|        |  an_dst| =20
> an_src|        |    _tot|     _mc|        |      ed|    miss| verflow=
|=20
> _search|t_search|
>   274234| 1590009|  271953|       0|    1809|       6|       0|      =
 0|  =20
> 24551|    7365|       0|  279991|  279867|      24|       0| 5438630|=
   89656|
>   280535|   25463|   19956|       0|     187|       0|       0|      =
 0|    =20
> 485|     263|       0|   20407|   20404|       3|       0|   12796|  =
   242|
>   288072|   25367|   19830|       0|     163|       0|       0|      =
 0|    =20
> 493|     256|       0|   20248|   20245|       3|       0|   17146|  =
   346|
>   294943|   25689|   19807|       0|     154|       0|       0|      =
 0|    =20
> 438|     250|       0|   20211|   20208|       3|       0|   21554|  =
   432|
>   301118|   25287|   19645|       0|     170|       0|       0|      =
 0|    =20
> 466|     236|       0|   20052|   20048|       3|       0|   25713|  =
   528|
>   307651|   25663|   20264|       0|     180|       0|       0|      =
 0|    =20
> 472|     234|       0|   20678|   20675|       3|       0|   30588|  =
   607|
>   313767|   25810|   20014|       0|     175|       0|       0|      =
 0|    =20
> 459|     237|       0|   20425|   20422|       3|       0|   33701|  =
   699|
>
>
>  =20
Then try to lower gc_elasticity, to 3, or even 2

echo 3 >/proc/sys/net/ipv4/route/gc_elasticity






