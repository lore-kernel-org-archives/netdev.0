From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [IPROUTE] compilation problem
Date: Fri, 16 Mar 2007 11:23:27 -0700
Message-ID: <20070316112327.27a933f0@freekitty>
References: <45F94248.4080003@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Nadia Derbey <Nadia.Derbey@bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:58105 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753241AbXCPSXg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Mar 2007 14:23:36 -0400
In-Reply-To: <45F94248.4080003@bull.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 15 Mar 2007 13:55:36 +0100
Nadia Derbey <Nadia.Derbey@bull.net> wrote:

> Hi,
> 
> Trying to compile iproute2 (downloaded from 
> http://developer.osdl.org/dev/iproute2/download/iproute2-2.6.20-070313.tar.gz) 
> I get the following error message.
> 
> gcc -D_GNU_SOURCE -O2 -Wstrict-prototypes -Wall -I../include 
> -DRESOLVE_HOSTNAMES -DCONFIG_GACT -DCONFIG_GACT_PROB   -c -o m_ipt.o m_ipt.c
> In file included from ../include/libiptc/libiptc.h:6,
>                   from ../include/iptables.h:5,
>                   from m_ipt.c:17:
> ../include/linux/netfilter_ipv4/ip_tables.h:115:39: error: 
> linux/netfilter/xt_tcpudp.h: No such file or directory
> make[1]: *** [m_ipt.o] Error 1
> rm emp_ematch.lex.c emp_ematch.yacc.c
> make[1]: Leaving directory `/home/lkernel/src/iproute-2.6.20-070313/tc'
> 
> 
> 
> This error goes away when I copy xt_tcpudp.h from the linux kernel tree 
> (include/linux/netfilter) to the the private iproute include directory.
> 
> Am I doing something wrong?

No more ip_tables API change breakage. For now suck xt_tcpudp.h from
current kernel tree into the iproute2 include directory. I'll fix
for later versions.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
