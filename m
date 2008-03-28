From: Jean Delvare <khali-PUYAD+kWke1g9hUCZPvPmw@public.gmane.org>
Subject: Re: COMPLETE is a poor global identifier
Date: Fri, 28 Mar 2008 15:38:33 +0100
Message-ID: <20080328153833.1074868a@hyperion.delvare>
References: <20080328032449.cbc09f3b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, i2c-GZX6beZjE8VD60Wz+7aTrA@public.gmane.org,
	Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <i2c-bounces-GZX6beZjE8VD60Wz+7aTrA@public.gmane.org>
In-Reply-To: <20080328032449.cbc09f3b.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <http://lists.lm-sensors.org/mailman/listinfo/i2c>,
	<mailto:i2c-request-GZX6beZjE8VD60Wz+7aTrA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.lm-sensors.org/pipermail/i2c>
List-Post: <mailto:i2c-GZX6beZjE8VD60Wz+7aTrA@public.gmane.org>
List-Help: <mailto:i2c-request-GZX6beZjE8VD60Wz+7aTrA@public.gmane.org?subject=help>
List-Subscribe: <http://lists.lm-sensors.org/mailman/listinfo/i2c>,
	<mailto:i2c-request-GZX6beZjE8VD60Wz+7aTrA@public.gmane.org?subject=subscribe>
Sender: i2c-bounces-GZX6beZjE8VD60Wz+7aTrA@public.gmane.org
Errors-To: i2c-bounces-GZX6beZjE8VD60Wz+7aTrA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

On Fri, 28 Mar 2008 03:24:49 -0700, Andrew Morton wrote:
> 
> powerpc allmodconfig:
> 
> In file included from drivers/char/rio/rio_linux.c:81:
> drivers/char/rio/cirrus.h:202:1: warning: "COMPLETE" redefined
> In file included from include/net/netns/ipv4.h:8,
>                  from include/net/net_namespace.h:13,
>                  from include/linux/seq_file.h:7,
>                  from include/asm/machdep.h:12,
>                  from include/asm/pci.h:17,
>                  from include/linux/pci.h:951,
>                  from drivers/char/rio/rio_linux.c:50:
> include/net/inet_frag.h:28:1: warning: this is the location of the previous definition
> 
> In file included from drivers/char/ip2/ip2main.c:128:
> drivers/char/ip2/i2ellis.h:608:1: warning: "COMPLETE" redefined
> In file included from include/net/netns/ipv4.h:8,
>                  from include/net/net_namespace.h:13,
>                  from include/linux/seq_file.h:7,
>                  from include/asm/machdep.h:12,
>                  from include/asm/pci.h:17,
>                  from include/linux/pci.h:951,
>                  from drivers/char/ip2/ip2main.c:95:
> include/net/inet_frag.h:28:1: warning: this is the location of the previous definition
> 
> 
> they should all be renamed.  These can cause runtime failures, so it's not
> a trivial thing.

How is this related to i2c?

-- 
Jean Delvare

_______________________________________________
i2c mailing list
i2c-GZX6beZjE8VD60Wz+7aTrA@public.gmane.org
http://lists.lm-sensors.org/mailman/listinfo/i2c
