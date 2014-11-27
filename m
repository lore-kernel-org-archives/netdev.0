From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] x86: bpf_jit_comp: simplify trivial boolean return
Date: Thu, 27 Nov 2014 10:49:35 -0800
Message-ID: <1417114175.4305.3.camel@perches.com>
References: <CAADnVQK3iui8cAmhi28=65p2CJbTu45fR98ri8Uh8xLRb=cwnA@mail.gmail.com>
	 <1417032059.16355.4.camel@perches.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1C9FDA63@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Quentin Lambert <lambert.quentin@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	"x86@kernel.org" <x86@kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1C9FDA63@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-11-27 at 12:25 +0000, David Laight wrote:
> Why the change in data?

btw: without gcov and using -O2

$ size arch/x86/net/bpf_jit_comp.o*
   text	   data	    bss	    dec	    hex	filename
   9671	      4	      0	   9675	   25cb	arch/x86/net/bpf_jit_comp.o.new
  10679	      4	      0	  10683	   29bb	arch/x86/net/bpf_jit_comp.o.old
