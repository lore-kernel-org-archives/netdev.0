From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6, sit: set prefix length 64 for link-local
 addresses
Date: Sun, 05 Oct 2003 21:28:46 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031005.212846.50858920.yoshfuji@linux-ipv6.org>
References: <20030926175405.GA31498@wsx.ksp.sk>
	<20030926201953.3dfc67bf.davem@redhat.com>
	<20031005091844.GA23676@wsx.ksp.sk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jan.oravec@6com.sk
In-Reply-To: <20031005091844.GA23676@wsx.ksp.sk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20031005091844.GA23676@wsx.ksp.sk> (at Sun, 5 Oct 2003 11:18:45 +0200), Jan Oravec <jan.oravec@6com.sk> says:

> The function sit_add_v4_addrs() calls ipv6_add_addr() with plen 64 if local
> endpoint of tunnel is not configured, so I do not see a reason to set plen
> to 128 if local endpoint is configured.

This patch seems logically wrong.

--yoshfuji
