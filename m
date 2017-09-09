From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ip_tunnel: fix setting ttl and tos value in
 collect_md mode
Date: Fri, 08 Sep 2017 20:47:53 -0700 (PDT)
Message-ID: <20170908.204753.178379645402959649.davem@davemloft.net>
References: <1504764515-13536-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org, ast@fb.com
To: yanhaishuang@cmss.chinamobile.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1504764515-13536-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Date: Thu,  7 Sep 2017 14:08:34 +0800

> ttl and tos variables are declared and assigned, but are not used in
> iptunnel_xmit() function.
> 
> Fixes: cfc7381b3002 ("ip_tunnel: add collect_md mode to IPIP tunnel")
> Cc: Alexei Starovoitov <ast@fb.com>
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

Applied.
