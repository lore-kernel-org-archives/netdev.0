From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH]Implementation for IPv6 MIB:ipv6InterfaceTable
Date: Tue, 14 Oct 2003 15:24:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031014152441.1be6b336.davem@redhat.com>
References: <200310141032.23998.mashirle@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Shirley Ma <mashirle@us.ibm.com>
In-Reply-To: <200310141032.23998.mashirle@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 14 Oct 2003 10:32:23 -0700
Shirley Ma <mashirle@us.ibm.com> wrote:

> +#ifdef CONFIG_SYSCTL
> +#include <linux/sysctl.h>
> +#endif

Please don't add ifdefs around header includes like this if
you can avoid it.

> +void inet6_ifinfo_notify(int event, struct inet6_dev *idev);
 ...
> +extern int ndisc_ifinfo_sysctl_change(ctl_table *ctl, int write, struct file 
 ...
> +extern void inet6_ifinfo_notify(int event, struct inet6_dev *idev);
 ...

These belong in header files, not scattered around in *.c files.

Thanks.
