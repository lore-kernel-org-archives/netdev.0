From: shemminger@osdl.org
Subject: Re: Unknown qdisc "netem"
Date: Wed, 13 Oct 2004 20:39:26 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <60664.63.170.215.71.1097725166.squirrel@www.osdl.org>
References: <41538C5B0002BF06@ims6b.cp.tin.it>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <41538C5B0002BF06@ims6b.cp.tin.it>
To: carlo.altarelli@virgilio.it
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> i'm tring to use netem under a 2.6.8.1 kernel,
> the error report is : "Unknown qdisc netem",
> I've just rebuild the kernel with these options about QoS:
>

More likely the problem is out of date versions of tc or picking up
the wrong version of tc from the PATH. Some distro's put tc in /sbin
but the current iproute2 'make install' puts it in /usr/sbin.  With
the latest iproute2 the netem support is in the shared library
/usr/lib/tc/q_netem.so. I could have built it into tc but wanted to
use netem as test case for the extensiblity with shared libraries,
and it solves build/link issues with older kernels.
