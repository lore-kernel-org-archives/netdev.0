From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH 0/4] netfilter fixes for 3.4-rc7
Date: Wed, 16 May 2012 21:48:40 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.1205162145520.2742@blackhole.kfki.hu>
References: <alpine.DEB.2.00.1205162037110.2742@blackhole.kfki.hu> <20120516.151836.786389543745557157.davem@davemloft.net> <alpine.DEB.2.00.1205162130090.2742@blackhole.kfki.hu> <20120516.153913.686915759183202821.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120516.153913.686915759183202821.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 16 May 2012, David Miller wrote:

> From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
> Date: Wed, 16 May 2012 21:34:55 +0200 (CEST)
> 
> > On Wed, 16 May 2012, David Miller wrote:
> > 
> >> > Could at least the patch with the subject
> >> > 
> >> >    netfilter: ipset: fix hash size checking in kernel
> >> > 
> >> >    The hash size must fit both into u32 (jhash) and the max value of
> >> >    size_t. The missing checking could lead to kernel crash, bug reported
> >> >    by Seblu.
> >> > 
> >> > be submitted into 3.4-rc7? Any non most-recent ipset package compiled with 
> >> > gcc-4.7 or above can trigger the bug.
> >> 
> >> And only root can trigger it if he gives bogus parameters right?
> > 
> > Yes, root can trigger it only, however it's a two sided bug: ipset < 6.12 
> > compiled with gcc >= 4.7 is broken and sends bogus data to the kernel, 
> > even when normal input parameters are supplied. And unpatched kernel can 
> > crash when acting on the bogus data. :-(
> 
> Ok, that's a more convincing argument.
> 
> I've applied the hash size validation patch to 'net'.

Thank you indeed - I received multiple reports of the crash, so the 
conditions are not uncommon.

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
