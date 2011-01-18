From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [patch 1/4] ipset: show correct line numbers in restore output
Date: Tue, 18 Jan 2011 21:15:39 +0100 (CET)
Message-ID: <alpine.DEB.2.00.1101182113280.28203@blackhole.kfki.hu>
References: <20110118142154.697547841@eitzenberger.org> <20110118142247.001984763@eitzenberger.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: holger@eitzenberger.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20110118142247.001984763@eitzenberger.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Holger,

First of all, thanks for the patches and reports.

On Tue, 18 Jan 2011, holger@eitzenberger.org wrote:

> When passing something like
> 
>   create foo6 hash:ip hashsize 64 family inet6
>   add foo6 20a1:1234:5678::/64
>   add foo6 20a1:1234:5679::/64
> 
> you get:
> 
>   ipset v5.2: Error in line 1: Syntax error: plain IP address must be supplied: 20a1:1234:5678::/64
> 
> Should be line 2 though.

Yes, good catch! Unfortunately your patch overwrites the correct line 
number when reported by the kernel. The proper fix was to add the missing 
session line number setting *before* the parser is called.

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlec@mail.kfki.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : KFKI Research Institute for Particle and Nuclear Physics
          H-1525 Budapest 114, POB. 49, Hungary
