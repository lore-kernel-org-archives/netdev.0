From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Realtek 8169 Lock-ups
Date: Wed, 14 Jan 2004 00:57:38 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040114005738.B21899@electric-eye.fr.zoreil.com>
References: <1073507006.5151.61.camel@localhost> <20040107232034.A22930@electric-eye.fr.zoreil.com> <1073596694.6378.6.camel@localhost> <4001080D.3090401@pobox.com> <20040111124957.A18068@electric-eye.fr.zoreil.com> <20040113000357.D5983@electric-eye.fr.zoreil.com> <1074020596.5336.0.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: dpollock@acm.org
Content-Disposition: inline
In-Reply-To: <1074020596.5336.0.camel@localhost>; from pollockd@magma.ca on Tue, Jan 13, 2004 at 02:03:16PM -0500
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

pollockd@magma.ca <pollockd@magma.ca> :
[...]
> With SMP enabled, I get the following, and the packet generator aborts
> quickly:
> 
> APIC error on CPU0: 40(40)
> eth0: Too much work at interrupt!
> eth0: Too much work at interrupt!

Well, it is not clear that the "Too muck work at interrupt" recovery logic
really recovers much (be it for vanilla or modified r8169 driver).

Does it behave differently if you make the "while (boguscnt > 0);" always
true in rtl8169_interrupt() and ask for a finite number of packets (say
pgset "count 1000" or more) ?

--
Ueimor
