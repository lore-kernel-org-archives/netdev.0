From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH] net: Enter net/ipv6/ even if CONFIG_IPV6=n
Date: Fri, 04 Mar 2011 09:01:54 -0800
Message-ID: <4D711B02.2060200@oracle.com>
References: <20110210180525.54ec83e9.sfr@canb.auug.org.au> <20110210095210.6fcf3011.randy.dunlap@oracle.com> <4D58DB20.5060401@trash.net> <20110303135414.bfcabb2a.randy.dunlap@oracle.com> <20110304093507.GG10761@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, Patrick McHardy <kaber@trash.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev@vger.kernel.org, linux-next@vger.kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110304093507.GG10761@canuck.infradead.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/04/11 01:35, Thomas Graf wrote:
> exthdrs_core.c and addrconf_core.c in net/ipv6/ contain bits which
> must be made available even if IPv6 is disabled.
> 
> net/ipv6/Makefile already correctly includes them if CONFIG_IPV6=n
> but net/Makefile prevents entering the subdirectory.
> 
> Signed-off-by: Thomas Graf <tgraf@infradead.org>

Acked-by: Randy Dunlap <randy.dunlap@oracle.com>

Thanks.

> 
> diff --git a/net/Makefile b/net/Makefile
> index a3330eb..a51d946 100644
> --- a/net/Makefile
> +++ b/net/Makefile
> @@ -19,9 +19,7 @@ obj-$(CONFIG_NETFILTER)		+= netfilter/
>  obj-$(CONFIG_INET)		+= ipv4/
>  obj-$(CONFIG_XFRM)		+= xfrm/
>  obj-$(CONFIG_UNIX)		+= unix/
> -ifneq ($(CONFIG_IPV6),)
> -obj-y				+= ipv6/
> -endif
> +obj-$(CONFIG_NET)		+= ipv6/
>  obj-$(CONFIG_PACKET)		+= packet/
>  obj-$(CONFIG_NET_KEY)		+= key/
>  obj-$(CONFIG_BRIDGE)		+= bridge/


-- 
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
