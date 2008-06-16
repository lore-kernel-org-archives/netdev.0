From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: packetloss, on e1000e worse than r8169?
Date: Tue, 17 Jun 2008 00:13:45 +0300
Message-ID: <20080616211213.M76390@visp.net.lb>
References: <20080616193501.M64730@visp.net.lb> <4856C3A7.9070703@cosmosbay.com> <20080616202210.M84100@visp.net.lb> <4856CEDC.6010706@intel.com> <20080616204411.M52834@visp.net.lb> <4856D1D6.7040207@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:49408 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752880AbYFPVOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 17:14:05 -0400
In-Reply-To: <4856D1D6.7040207@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>Are you sure nf_conntrack or ip route cache is not killing you ?
>
>Filling 512 or 1024 RX ring on Gigabit link can be very fast, especially 
>if ip route cache is full.
>
>rtstat -c10 -i1

conntrack disabled, it is just enabled for second on load and then unloaded.

MegaRouter-KARAM ~ # rtstat -c10 -i1
rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|
 entries|  in_hit|in_slow_|in_slow_|in_no_ro|  in_brd|in_marti|in_marti|
out_hit|out_slow|out_slow|gc_total|gc_ignor|gc_goal_|gc_dst_o|in_hlist|out_hlis|
        |        |     tot|      mc|     ute|        |  an_dst|  an_src|     
  |    _tot|     _mc|        |      ed|    miss| verflow| _search|t_search|
   63448|229209146|22225578|   13754|      12|    2822|       0|     104|  
54647|   27606|     570|21782075|21776859|      74|       0|215222374|   61294|
   66085|  141462|    5268|       8|       0|       4|       0|       0|     
 4|       2|       0|    5274|    5274|       0|       0|  254424|      10|
   59947|  132660|   20570|       4|       0|       4|       0|       0|     
 8|      14|       0|   20584|   20584|       0|       0|  185738|      24|
   56995|  132416|   16918|      12|       0|       2|       0|       0|     
 6|       4|       0|   16932|   16932|       0|       0|   68378|       8|
   56422|  137058|   12336|       8|       0|       0|       0|       0|     
 8|       2|       0|   12344|   12344|       0|       0|   84022|       4|
   56819|  140526|    9896|      10|       0|       0|       0|       0|     
 6|       0|       0|    9898|    9896|       0|       0|   99138|       4|
   57580|  136936|    8370|      10|       0|       2|       0|       0|     
 8|       6|       2|    8378|    8378|       0|       0|  110834|      22|
   51583|  120138|   26828|      20|       0|       0|       0|       0|     
 4|       8|       0|   26848|   26848|       0|       0|   99292|      24|
   49354|  128076|   21606|      14|       0|       2|       0|       0|     
 0|      10|       0|   21626|   21626|       0|       0|   60546|      12|



--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

