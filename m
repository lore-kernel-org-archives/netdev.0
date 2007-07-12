From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: iproute2 2.6.22-070710 ,  mp_ematch.y:11: unrecognized:
 %error-verbose , ...
Date: Wed, 11 Jul 2007 21:10:09 -0700
Message-ID: <20070711211009.088c814e@freepuppy.rosehill.hemminger.net>
References: <20070710190103.09ffa0e8@freepuppy.rosehill.hemminger.net>
	<Pine.LNX.4.64.0707112034250.9153@filesrv1.baby-dragons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lartc@mailman.ds9a.nl
To: "Mr. James W. Laferriere" <babydr@baby-dragons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:33709 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750811AbXGLEK3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 00:10:29 -0400
In-Reply-To: <Pine.LNX.4.64.0707112034250.9153@filesrv1.baby-dragons.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 11 Jul 2007 20:38:43 -0700 (PDT)
"Mr. James W. Laferriere" <babydr@baby-dragons.com> wrote:

>  	Hello Stephen (& All) ,  Maybe next build of the tarball one could tar 
> up the base directory name as well .  ie: iproute2-2.6.22-070710/ .
>  	The error below while being (quite probably) manually correctable isn't 
> something I'd expect to see in a release .
>  		Twyl ,  JimL
> 
> ps: I am not subscribed to netdev (I am quite sure) .
> 
> $ ./configure
> TC schedulers
>   ATM    no
> 
> $ make
> make[1]: Entering directory `/home/archive/iproute2-2_6_22-070710/lib'
> ...snip...
> gcc -D_GNU_SOURCE -O2 -Wstrict-prototypes -Wall -I../include -DRESOLVE_HOSTNAMES -DCONFIG_GACT -DCONFIG_GACT_PROB   -c -o m_ematch.o m_ematch.c
> bison -d -t -v -o emp_ematch.yacc.c emp_ematch.y
> emp_ematch.y:11: unrecognized: %error-verbose
> emp_ematch.y:11:    Skipping to next %
> make[1]: *** [emp_ematch.yacc.c] Error 1
> make[1]: Leaving directory `/home/archive/iproute2-2_6_22-070710/tc'
> make: *** [all] Error 2
> jiml@filesrv1:/home/archive

Which version of bison. There have been issues where bison / flex don't
always stay source compatible across releases.
