From: Adrian Bunk <bunk@fs.tum.de>
Subject: 2.4.26-pre1: SCTP compile error
Date: Thu, 26 Feb 2004 22:27:59 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040226212759.GV5499@fs.tum.de>
References: <Pine.LNX.4.58L.0402251605360.5003@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58L.0402251605360.5003@logos.cnet>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Feb 25, 2004 at 04:09:20PM -0300, Marcelo Tosatti wrote:
>...
> It contains a big SCTP merge (to match 2.6 API), networking updates,
>...

I got the compile error forwarded below using gcc 2.95.3 .

cu
Adrian



...
gcc-2.95 -D__KERNEL__ -I/home/bunk/linux/kernel-2.4/linux-2.4.26-pre1-full/include -Wall -Wstrict-prototypes -Wno-trigraphs -O2 -fno-strict-aliasing -fno-common -fomit-frame-pointer -pipe -mpreferred-stack-boundary=2 -march=i686 -malign-functions=4   -nostdinc -iwithprefix include -DKBUILD_BASENAME=ipv6  -c -o ipv6.o ipv6.c
In file included from ipv6.c:77:
/home/bunk/linux/kernel-2.4/linux-2.4.26-pre1-full/include/net/sctp/sctp.h:119: warning: `MSECS_TO_JIFFIES' redefined
/home/bunk/linux/kernel-2.4/linux-2.4.26-pre1-full/include/net/irda/irda.h:89: warning: this is the location of the previous definition
ipv6.c: In function `sctp_v6_xmit':
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c:189: request for member `in6_u' in something not a structure or union
ipv6.c: In function `sctp_v6_get_dst':
ipv6.c:213: request for member `in6_u' in something not a structure or union
ipv6.c:213: request for member `in6_u' in something not a structure or union
ipv6.c:213: request for member `in6_u' in something not a structure or union
ipv6.c:213: request for member `in6_u' in something not a structure or union
ipv6.c:213: request for member `in6_u' in something not a structure or union
ipv6.c:213: request for member `in6_u' in something not a structure or union
ipv6.c:213: request for member `in6_u' in something not a structure or union
ipv6.c:213: request for member `in6_u' in something not a structure or union
ipv6.c:213: request for member `in6_u' in something not a structure or union
ipv6.c:213: request for member `in6_u' in something not a structure or union
ipv6.c:213: request for member `in6_u' in something not a structure or union
ipv6.c:213: request for member `in6_u' in something not a structure or union
ipv6.c:213: request for member `in6_u' in something not a structure or union
ipv6.c:213: request for member `in6_u' in something not a structure or union
ipv6.c:213: request for member `in6_u' in something not a structure or union
ipv6.c:213: request for member `in6_u' in something not a structure or union
ipv6.c:213: request for member `in6_u' in something not a structure or union
ipv6.c:213: request for member `in6_u' in something not a structure or union
ipv6.c:213: request for member `in6_u' in something not a structure or union
ipv6.c:213: request for member `in6_u' in something not a structure or union
ipv6.c:213: request for member `in6_u' in something not a structure or union
ipv6.c:213: request for member `in6_u' in something not a structure or union
ipv6.c:213: request for member `in6_u' in something not a structure or union
ipv6.c:213: request for member `in6_u' in something not a structure or union
ipv6.c:219: request for member `in6_u' in something not a structure or union
ipv6.c:219: request for member `in6_u' in something not a structure or union
ipv6.c:219: request for member `in6_u' in something not a structure or union
ipv6.c:219: request for member `in6_u' in something not a structure or union
ipv6.c:219: request for member `in6_u' in something not a structure or union
ipv6.c:219: request for member `in6_u' in something not a structure or union
ipv6.c:219: request for member `in6_u' in something not a structure or union
ipv6.c:219: request for member `in6_u' in something not a structure or union
ipv6.c:219: request for member `in6_u' in something not a structure or union
ipv6.c:219: request for member `in6_u' in something not a structure or union
ipv6.c:219: request for member `in6_u' in something not a structure or union
ipv6.c:219: request for member `in6_u' in something not a structure or union
ipv6.c:219: request for member `in6_u' in something not a structure or union
ipv6.c:219: request for member `in6_u' in something not a structure or union
ipv6.c:219: request for member `in6_u' in something not a structure or union
ipv6.c:219: request for member `in6_u' in something not a structure or union
ipv6.c:219: request for member `in6_u' in something not a structure or union
ipv6.c:219: request for member `in6_u' in something not a structure or union
ipv6.c:219: request for member `in6_u' in something not a structure or union
ipv6.c:219: request for member `in6_u' in something not a structure or union
ipv6.c:219: request for member `in6_u' in something not a structure or union
ipv6.c:219: request for member `in6_u' in something not a structure or union
ipv6.c:219: request for member `in6_u' in something not a structure or union
ipv6.c:219: request for member `in6_u' in something not a structure or union
make[3]: *** [ipv6.o] Error 1
make[3]: Leaving directory `/home/bunk/linux/kernel-2.4/linux-2.4.26-pre1-full/net/sctp'
make[2]: *** [first_rule] Error 2
make[2]: Leaving directory `/home/bunk/linux/kernel-2.4/linux-2.4.26-pre1-full/net/sctp'
make[1]: *** [_subdir_sctp] Error 2
make[1]: Leaving directory `/home/bunk/linux/kernel-2.4/linux-2.4.26-pre1-full/net'
make: *** [_dir_net] Error 2
