From: James Morris <jmorris@intercode.com.au>
Subject: Re: [PATCH] more CONFIG_NET removals
Date: Tue, 24 Jun 2003 22:01:25 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0306242158250.6102-100000@excalibur.intercode.com.au>
References: <20030620112504.GM24357@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matthew Wilcox <willy@debian.org>
In-Reply-To: <20030620112504.GM24357@parcelfarce.linux.theplanet.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 20 Jun 2003, Matthew Wilcox wrote:

> Anyone see a problem with this patch against 2.5.72?  It worksforme.

> +net-$(CONFIG_COMPAT)		+= compat.o
> +net-$(CONFIG_MODULES)		+= netsyms.o
> +net-$(CONFIG_SYSCTL)		+= sysctl_net.o
> +obj-$(CONFIG_NET)		:= socket.o core/ $(net-y)

Some of the net/compat.c functions (e.g. compat_sys_setsockopt) are 
still needed to allow the kernel to build.  Perhaps use cond_syscall() for 
these?


- James
-- 
James Morris
<jmorris@intercode.com.au>
