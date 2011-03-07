From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Enter net/ipv6/ even if CONFIG_IPV6=n
Date: Mon, 07 Mar 2011 12:51:19 -0800 (PST)
Message-ID: <20110307.125119.260081518.davem@davemloft.net>
References: <20110303135414.bfcabb2a.randy.dunlap@oracle.com>
	<20110304093507.GG10761@canuck.infradead.org>
	<4D711B02.2060200@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <4D711B02.2060200@oracle.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Fri, 04 Mar 2011 09:01:54 -0800

> On 03/04/11 01:35, Thomas Graf wrote:
>> exthdrs_core.c and addrconf_core.c in net/ipv6/ contain bits which
>> must be made available even if IPv6 is disabled.
>> 
>> net/ipv6/Makefile already correctly includes them if CONFIG_IPV6=n
>> but net/Makefile prevents entering the subdirectory.
>> 
>> Signed-off-by: Thomas Graf <tgraf@infradead.org>
> 
> Acked-by: Randy Dunlap <randy.dunlap@oracle.com>

Applied, thanks.
