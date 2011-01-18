From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [patch 2/4] ipset: make IPv4 and IPv6 address handling similar
Date: Tue, 18 Jan 2011 21:18:46 +0100 (CET)
Message-ID: <alpine.DEB.2.00.1101182116150.28203@blackhole.kfki.hu>
References: <20110118142154.697547841@eitzenberger.org> <20110118142247.498399684@eitzenberger.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: holger@eitzenberger.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20110118142247.498399684@eitzenberger.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 18 Jan 2011, holger@eitzenberger.org wrote:

> While the following works for AF_INET:
> 
>  ipset add foo 192.168.1.1/32
> 
> this does not work for AF_INET6:
> 
>  ipset add foo6 20a1:1:2:3:4:5:6:7/128
>  ipset v5.2: Syntax error: plain IP address must be supplied: 20a1:1:2:3:4:5:6:7/128

Yeah, the usual issue: should IPv4/32 and IPv6/128 be handled as a plain 
IPv4/v6 address when the manual says "enter a plain IPv4/v6 address" :-).

The complete fix was to add the exception to the generic IP address parser 
function.

Best regards,
Jozsef  
-
E-mail  : kadlec@blackhole.kfki.hu, kadlec@mail.kfki.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : KFKI Research Institute for Particle and Nuclear Physics
          H-1525 Budapest 114, POB. 49, Hungary
