From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [patch 4/4] ipset: fix build with NDEBUG defined
Date: Tue, 18 Jan 2011 21:20:01 +0100 (CET)
Message-ID: <alpine.DEB.2.00.1101182118480.28203@blackhole.kfki.hu>
References: <20110118142154.697547841@eitzenberger.org> <20110118142248.489615870@eitzenberger.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: holger@eitzenberger.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20110118142248.489615870@eitzenberger.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 18 Jan 2011, holger@eitzenberger.org wrote:

> The usage of the gcc option -Wunused-parameter interferes badly with
> the assert() macros.  In case -DNDEBUG is specified build fails with:
> 
>   cc1: warnings being treated as errors
>   print.c: In function 'ipset_print_family':
>   print.c:92: error: unused parameter 'opt'
>   print.c: In function 'ipset_print_port':
>   print.c:413: error: unused parameter 'opt'
>   print.c: In function 'ipset_print_proto':
> 
> A possible fix is just to remove -Wunused, as -Wextra + -Wunused enables
> -Wunused-paramter.

I chose to keep the compiler flags and add the required attribute to the 
function parameters instead.

Many thanks again, Holger!

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlec@mail.kfki.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : KFKI Research Institute for Particle and Nuclear Physics
          H-1525 Budapest 114, POB. 49, Hungary
