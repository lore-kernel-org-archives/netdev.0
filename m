From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: ip_set: protocol %u message -- useful?
Date: Thu, 13 Feb 2014 11:30:20 +0100 (CET)
Message-ID: <alpine.DEB.2.10.1402131117120.16734@blackhole.kfki.hu>
References: <CAKb7UvhsLi2Sv4SWA2nVTgoFV8dzrY=3R1-SUk9D-aa0VdizSA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>, Vitaly Lavrov <lve@guap.ru>
To: Ilia Mirkin <imirkin@alum.mit.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKb7UvhsLi2Sv4SWA2nVTgoFV8dzrY=3R1-SUk9D-aa0VdizSA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 13 Feb 2014, Ilia Mirkin wrote:

> I've recently noticed a lot of
> 
> [356872.380595] ip_set: protocol 6

That means the ip_set module has been loaded in multiple times.
 
> messages in my dmesg. This might be because of some local
> configuration changes I've made, or perhaps a kernel upgrade. Either
> way, it appears this message has been a pr_notice since the original
> code added it in a7b4f989a62 ("netfilter: ipset: IP set core
> support").
> 
> Does this message provide a lot of value? Or could it be made into a pr_debug?

That's a report message on the protocol version used by the ipset 
subsystem. There was (and possibly will be) multiple protocols, so it 
helps to catch basic userpsace/kernelspace communication issues.
 
> FWIW commit 1785e8f473 ("netfiler: ipset: Add net namespace for
> ipset"), merged in v3.13-rc1 changed the code around which may have
> made it more likely to appear in dmesg (with the namespace stuff). Not
> sure though. I don't (purposely) use namespaces.

Namespaces can explain why you see the message so many times, but then you 
must have namespaces activated.
 
> I'm happy to put together a patch demoting it to pr_debug if people
> think it's OK.

I'm fine with it, it's OK.

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
