From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: baycom_epp.c compile failure
Date: Sun, 10 Dec 2006 11:56:17 -0800
Message-ID: <20061210115617.c98c5369.randy.dunlap@oracle.com>
References: <20061210005632.d980f651.akpm@osdl.org>
	<20061210125735.GA3058@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:46380 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762430AbWLJTzh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Dec 2006 14:55:37 -0500
To: Ralf Baechle <ralf@linux-mips.org>
In-Reply-To: <20061210125735.GA3058@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 10 Dec 2006 12:57:35 +0000 Ralf Baechle wrote:

> On Sun, Dec 10, 2006 at 12:56:32AM -0800, Andrew Morton wrote:
> 
> > drivers/net/hamradio/baycom_epp.c: In function 'baycom_probe':
> > drivers/net/hamradio/baycom_epp.c:1180: error: 'ax25_nocall' undeclared (first use in this function)
> > drivers/net/hamradio/baycom_epp.c:1180: error: (Each undeclared identifier is reported only once
> > drivers/net/hamradio/baycom_epp.c:1180: error: for each function it appears in.)
> 
> Will look into it later today.

and after baycom:

net/ax25/ax25_route.c:295: warning: implicit declaration of function 'ax2asc'
net/ax25/ax25_route.c:295: warning: assignment makes pointer from integer without a cast
net/ax25/ax25_route.c:316: warning: format '%s' expects type 'char *', but argument 3 has ty
pe 'int'
net/ax25/ax25_uid.c:184: warning: implicit declaration of function 'ax2asc'
net/ax25/ax25_uid.c:184: warning: format '%s' expects type 'char *', but argument 4 has type
 'int'
net/ax25/af_ax25.c:1893: warning: implicit declaration of function 'ax2asc'
net/ax25/af_ax25.c:1894: warning: format '%s' expects type 'char *', but argument 5 has type
 'int'
net/ax25/af_ax25.c:1895: warning: format '%s' expects type 'char *', but argument 3 has type
 'int'
net/ax25/af_ax25.c:1900: warning: format '%s' expects type 'char *', but argument 3 has type
 'int'
net/netrom/af_netrom.c:1292: warning: implicit declaration of function 'ax2asc'
net/netrom/af_netrom.c:1292: warning: format '%-9s' expects type 'char *', but argument 3 ha
s type 'int'
net/netrom/af_netrom.c:1293: warning: format '%-9s' expects type 'char *', but argument 3 ha
s type 'int'
net/netrom/af_netrom.c:1319: warning: format '%-9s' expects type 'char *', but argument 3 ha
s type 'int'
net/netrom/nr_route.c:900: warning: implicit declaration of function 'ax2asc'
net/netrom/nr_route.c:903: warning: format '%-9s' expects type 'char *', but argument 3 has 
type 'int'
net/netrom/nr_route.c:989: warning: format '%-9s' expects type 'char *', but argument 4 has 
type 'int'
net/netrom/nr_route.c:994: warning: format '%s' expects type 'char *', but argument 3 has ty
pe 'int'
net/rose/af_rose.c:1397: warning: implicit declaration of function 'ax2asc'
net/rose/af_rose.c:1397: warning: format '%-9s' expects type 'char *', but argument 4 has ty
pe 'int'
net/rose/af_rose.c:1402: warning: assignment makes pointer from integer without a cast
net/rose/rose_route.c:871: warning: implicit declaration of function 'ax2asc'
net/rose/rose_route.c:871: warning: format '%s' expects type 'char *', but argument 2 has ty
pe 'int'
net/rose/rose_route.c:1185: warning: pointer/integer type mismatch in conditional expression
net/rose/rose_route.c:1196: warning: format '%s' expects type 'char *', but argument 3 has t
ype 'int'
net/rose/rose_route.c:1270: warning: format '%-9s' expects type 'char *', but argument 5 has
 type 'int'
net/rose/rose_route.c:1281: warning: format '%-9s' expects type 'char *', but argument 5 has
 type 'int'
net/rose/rose_subr.c:340: warning: implicit declaration of function 'asc2ax'
net/rose/rose_subr.c:460: warning: implicit declaration of function 'ax2asc'
net/rose/rose_subr.c:460: warning: assignment makes pointer from integer without a cast
net/rose/rose_subr.c:475: warning: assignment makes pointer from integer without a cast

---
~Randy
