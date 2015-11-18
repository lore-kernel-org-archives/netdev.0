From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Asterisk deadlocks since Kernel 4.1
Date: Wed, 18 Nov 2015 22:40:27 +0100
Message-ID: <1447882827.575319.443677441.6F45D05F@webmail.messagingengine.com>
References: <564B3D35.50004@profihost.ag> <alpine.DEB.2.11.1511171936030.3761@nanos>
 <564B7F9D.5060701@profihost.ag>
 <alpine.DEB.2.11.1511172041480.3761@nanos>
 <564CDE2F.8000201@profihost.ag> <564CEB0C.40006@redhat.com>
 <564CEF5D.3080005@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stefan Priebe <s.priebe@profihost.ag>,
	Florian Weimer <fweimer@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <564CEF5D.3080005@profihost.ag>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 18, 2015, at 22:36, Stefan Priebe wrote:
> sorry here it is. What I'm wondering is why is there ipv6 stuff? I don't 
> have ipv6 except for link local. Could it be this one?
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=505105#c79
> 
> Thread 31 (Thread 0x7f295c011700 (LWP 26654)):
> #0  0x00007f295de3287d in recvmsg () at 
> ../sysdeps/unix/syscall-template.S:82
> #1  0x00007f295de52fcc in make_request (fd=35, pid=26631, 
> seen_ipv4=<optimized out>, seen_ipv6=<optimized out>,
>      in6ai=<optimized out>, in6ailen=<optimized out>) at 
> ../sysdeps/unix/sysv/linux/check_pf.c:119
> #2  0x00007f295de5344a in __check_pf (seen_ipv4=0x7f295c00e85f, 
> seen_ipv6=0x7f295c00e85e, in6ai=0x7f295c00e840,
>      in6ailen=0x7f295c00e838) at
>      ../sysdeps/unix/sysv/linux/check_pf.c:271
> #3  0x00007f295de10007 in *__GI_getaddrinfo (name=0x7f295c00e8b0 
> "10.12.12.55", service=0x7f295c00e8bc "2135",
>      hints=0x7f295c00e910, pai=0x7f295c00e908) at 
> ../sysdeps/posix/getaddrinfo.c:2389

Can you also get a /proc/pid/stack stacktrace?

Thanks,
Hannes
