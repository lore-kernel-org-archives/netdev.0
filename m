From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: kernel 2.6.25-rc7 highly unstable on high load
Date: Fri, 28 Mar 2008 06:50:14 +0200
Message-ID: <20080328045015.M50099@visp.net.lb>
References: <47EBC641.8040405@cosmosbay.com> <20080327183745.M9944@visp.net.lb> <47EBEDC9.6080100@cosmosbay.com> <20080327.150308.205829519.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: kaber@trash.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>, dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:60247 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750911AbYC1EuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 00:50:22 -0400
In-Reply-To: <20080327.150308.205829519.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After patching , without ifb and "shapers".

[11807.126790] dst_total: 807311 delayed: 785973 work_perf: 0 expires: 45928 
elapsed: 71977 us
[11853.118939] dst_total: 810625 delayed: 785973 work_perf: 0 expires: 52928 
elapsed: 72092 us
[11906.110627] dst_total: 814329 delayed: 785973 work_perf: 0 expires: 59929 
elapsed: 71415 us
[11966.101684] dst_total: 818621 delayed: 785973 work_perf: 0 expires: 67929 
elapsed: 71566 us
[12034.092650] dst_total: 823641 delayed: 785973 work_perf: 0 expires: 76927 
elapsed: 72856 us
[12111.080909] dst_total: 829008 delayed: 785973 work_perf: 0 expires: 85927 
elapsed: 73175 us
[12197.066708] dst_total: 835397 delayed: 785973 work_perf: 0 expires: 94928 
elapsed: 72001 us
[12292.054049] dst_total: 842092 delayed: 785972 work_perf: 1 expires: 104927 
elapsed: 73341 us
[12397.038451] dst_total: 849712 delayed: 785972 work_perf: 0 expires: 115926 
elapsed: 74072 us
[12513.032054] dst_total: 858081 delayed: 785972 work_perf: 0 expires: 119915 
elapsed: 77027 us
[12633.016029] dst_total: 866064 delayed: 785972 work_perf: 0 expires: 119913 
elapsed: 87431 us
[12752.987981] dst_total: 874067 delayed: 785972 work_perf: 0 expires: 119923 
elapsed: 76570 us
[12872.981870] dst_total: 882006 delayed: 785972 work_perf: 0 expires: 119911 
elapsed: 88655 us
[12992.950062] dst_total: 889918 delayed: 785972 work_perf: 0 expires: 119924 
elapsed: 76035 us


rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|
rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|
rt_cache|
 entries|  in_hit|in_slow_|in_slow_|in_no_ro|  in_brd|in_marti|in_marti| 
out_hit|out_slow|out_slow|gc_total|gc_ignor|gc_goal_|gc_dst_o|in_hlist|
out_hlis|
        |        |     tot|      mc|     ute|        |  an_dst|  
an_src|        |    _tot|     _mc|        |      ed|    miss| verflow| 
_search|t_search|
  896238|135781150|112584149|       0|  475839|    1708|       0|      18| 
3234260| 2340122|       0|115324498|115284650|   35962|       0|484427466|
15419774|




On Thu, 27 Mar 2008 15:03:08 -0700 (PDT), David Miller wrote
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Thu, 27 Mar 2008 19:56:09 +0100
> 
> > Maybe some netfilter problem ?
> > 
> > Please tell us more about your machine ;)
> 
> I'm beginning to suspect it's IFB and shaping somehow.
> 
> If those variables could be eliminated by eliminating them
> from the configuration, it would help diagnose this a lot.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

