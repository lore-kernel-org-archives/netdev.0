From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: IPv6 badness continues
Date: Sat, 08 Jan 2005 20:12:00 -0500
Message-ID: <41E084E0.9070709@pobox.com>
References: <41DA3A60.8050102@pobox.com> <20050108042509.GA1959@gondor.apana.org.au> <41E01746.3080501@pobox.com> <20050108183545.GA6413@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>,
        YOSHIFUJI Hideaki / ???????????? <yoshfuji@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050108183545.GA6413@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Here is the corrected version.

I applied the patch and tried it out.  The kernel was practically 
unusable, as the warning hit as soon as the kernel booted:

> Jan  8 20:06:44 pretzel kernel: Badness in ip6_ins_rt at net/ipv6/route.c:382
> Jan  8 20:06:44 pretzel kernel:  [<f8bee2be>] ip6_ins_rt+0x7e/0x80 [ipv6]
> Jan  8 20:06:44 pretzel kernel:  [<f8bec43e>] __ipv6_ifa_notify+0x12e/0x1a0 [ipv
> 6]
> Jan  8 20:06:44 pretzel kernel:  [<f8bec4e3>] ipv6_ifa_notify+0x33/0x50 [ipv6]
> Jan  8 20:06:44 pretzel kernel:  [<f8be9a10>] init_loopback+0x90/0x110 [ipv6]
> Jan  8 20:06:44 pretzel kernel:  [<f8be9ebf>] addrconf_notify+0xff/0x1a0 [ipv6]
> Jan  8 20:06:44 pretzel kernel:  [<c012fc0d>] notifier_call_chain+0x2d/0x50
> Jan  8 20:06:44 pretzel kernel:  [<c02fc7e7>] dev_open+0x77/0xa0
> Jan  8 20:06:44 pretzel kernel:  [<c02fde43>] dev_change_flags+0x53/0x130
> Jan  8 20:06:44 pretzel kernel:  [<c0342137>] devinet_ioctl+0x257/0x5d0
> Jan  8 20:06:44 pretzel kernel:  [<c03444c6>] inet_ioctl+0x66/0xb0
> Jan  8 20:06:44 pretzel kernel:  [<c02f34c9>] sock_ioctl+0xc9/0x250
> Jan  8 20:06:44 pretzel kernel:  [<c017404a>] sys_ioctl+0xca/0x230
> Jan  8 20:06:44 pretzel kernel:  [<c010309d>] sysenter_past_esp+0x52/0x75
