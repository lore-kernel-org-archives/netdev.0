From: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2004@gmx.net>
Subject: Re: forcedeth: Compilation fails for kernel 2.4.24
Date: Sun, 01 Feb 2004 19:34:21 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <401D46AD.2040009@gmx.net>
References: <401D2F80.20007@dim.uchile.cl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Pablo R. Dartnell" <dartnell@dim.uchile.cl>
In-Reply-To: <401D2F80.20007@dim.uchile.cl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Pablo,

Pablo R. Dartnell wrote:
> Hi,
> 
> Let me tell you first that I am not a programmer, so I am afraid all I
> can tell you here is plainly what happened, but not why or what could
> fix it. I found these addresses at the web page:
> http://www.hailfinger.org/carldani/linux/patches/forcedeth/,
> and I thought I should let you know what happened when trying to compile
> the 2.4.24 kernel with the "forcedeth_2_4_patch_v22.txt" patch applied.

Your report gives all necessary details.

> Here are the last few lines of output when running "make modules_install":
> [...]
> forcedeth.c: In function `probe_nic':
> forcedeth.c:1321: warning: implicit declaration of function
> `SET_NETDEV_DEV'
> forcedeth.c:1321: structure has no member named `dev'

The problem is known and there are two possible solutions:
1. Apply patch-2.4.25-pre8.gz from
ftp://ftp.kernel.org/pub/linux/kernel/v2.4/testing/
2. Send me some mail requesting the necessary compatibility headers

Basically, forcedeth 0.22 and later versions need either a 2.6 series
kernel or 2.4.25-pre7 or later. That allowed me to remove much of the
compatibility cruft.


HTH,
Carl-Daniel
-- 
http://www.hailfinger.org/
