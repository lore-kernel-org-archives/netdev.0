From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ipv4: fix do_ip_setsockopt optlen check for
 IP_MULTICAST_IF
Date: Thu, 24 Sep 2009 15:44:33 -0700 (PDT)
Message-ID: <20090924.154433.202033577.davem@davemloft.net>
References: <4AB1FE2A.1060906@cn.fujitsu.com>
	<20090922.133819.173686372.davem@davemloft.net>
	<4AB97CB6.4000004@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dfeng@redhat.com, kaber@trash.net, yoshfuji@linux-ipv6.org,
	jmorris@namei.org, pekkas@netcore.fi, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: shanwei@cn.fujitsu.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752716AbZIXWoQ@vger.kernel.org>
In-Reply-To: <4AB97CB6.4000004@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shan Wei <shanwei@cn.fujitsu.com>
Date: Wed, 23 Sep 2009 09:41:10 +0800

> [PATCH BUGFIX] ipv4: check optlen for IP_MULTICAST_IF option
> 
> Due to man page of setsockopt, if optlen is not valid, kernel should return
> -EINVAL. But a simple testcase as following, errno is 0, which means setsockopt
> is successful.
> 	addr.s_addr = inet_addr("192.1.2.3");
> 	setsockopt(s, IPPROTO_IP, IP_MULTICAST_IF, &addr, 1);
> 	printf("errno is %d\n", errno);
> 
> Xiaotian Feng(dfeng@redhat.com) caught the bug. We fix it firstly checking
> the availability of optlen and then dealing with the logic like other options. 
> 
> Reported-by: Xiaotian Feng <dfeng@redhat.com> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
> Acked-by: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>

Applied.
