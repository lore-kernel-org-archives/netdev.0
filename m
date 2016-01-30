From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] ipv4: ipconfig: avoid unused ic_proto_used symbol
Date: Fri, 29 Jan 2016 19:39:32 -0800 (PST)
Message-ID: <20160129.193932.2217883845698146411.davem@davemloft.net>
References: <2132183.67sfLfLqZb@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com,
	linux-arm-kernel@lists.infradead.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2132183.67sfLfLqZb@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 28 Jan 2016 17:39:24 +0100

> When CONFIG_PROC_FS, CONFIG_IP_PNP_BOOTP, CONFIG_IP_PNP_DHCP and
> CONFIG_IP_PNP_RARP are all disabled, we get a warning about the
> ic_proto_used variable being unused:
> 
> net/ipv4/ipconfig.c:146:12: error: 'ic_proto_used' defined but not used [-Werror=unused-variable]
> 
> This avoids the warning, by making the definition conditional on
> whether a dynamic IP configuration protocol is configured. If not,
> we know that the value is always zero, so we can optimize away the
> variable and all code that depends on it.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
