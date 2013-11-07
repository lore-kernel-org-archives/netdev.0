From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: ipv6: a question about ECMP
Date: Thu, 07 Nov 2013 18:33:20 +0800
Message-ID: <527B6C70.3010507@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org, David Miller <davem@davemloft.net>,
	nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:36125 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750909Ab3KGKfm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Nov 2013 05:35:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

  After reading the ip6_pol_route(), i have a question about ECMP. Why we call
the rt6_multipath_select() after calling rt6_select()?
  In my opinion, the route returned by rt6_select() has a highest score, but the route
returned by rt6_multipath_select() may has a lower score than the former, because the
ECMP don't take the route preference into consideration. That means that the kernel will
choose a less-desirable route.

Thanks,
  Duan
  
