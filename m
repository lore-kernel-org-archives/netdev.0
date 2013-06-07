From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: NULL pointer dereference when loading the gre module (3.10.0-rc4)
Date: Fri, 7 Jun 2013 10:31:55 +0200
Message-ID: <20130607083155.GB15083@uio.no>
References: <20130606221656.GA11475@uio.no>
 <20130607030648.GA28618@home.goodmis.org>
 <1370577588.24311.407.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Steven Rostedt <rostedt@goodmis.org>, linux-kernel@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1370577588.24311.407.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 06, 2013 at 08:59:48PM -0700, Eric Dumazet wrote:
> Steinar, please make sure you recompiled your modules, because this
> looks like you loaded old modules.

I compiled the kernel using make-kpkg, so I don't see how that would happen.
Also, the timestamps indicate everything is fine:

-rw-r--r-- 1 root root 2574976 Jun  6 00:39 /boot/vmlinuz-3.10.0-rc4
-rw-r--r-- 1 root root   22856 Jun  6 00:39 /lib/modules/3.10.0-rc4/kernel/net/ipv4/ip_gre.ko

Or from the source tree:

-rw-r--r-- 1 root root 2574976 Jun  6 00:36 arch/x86/boot/bzImage
-rw-r--r-- 1 root root   22800 Jun  6 00:39 ./net/ipv4/ip_gre.ko

/* Steinar */
-- 
Homepage: http://www.sesse.net/
