From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: emp_ematch.y:11: unrecognized: %error-verbose
Date: Fri, 25 Jul 2008 22:43:09 -0700
Message-ID: <20080725224309.0ae24c5e@speedy>
References: <Pine.LNX.4.64.0807252016450.18879@filesrv1.baby-dragons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: "Mr. James W. Laferriere" <babydr@baby-dragons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:51805 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751324AbYGZFnK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Jul 2008 01:43:10 -0400
In-Reply-To: <Pine.LNX.4.64.0807252016450.18879@filesrv1.baby-dragons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 25 Jul 2008 20:32:42 -0800 (AKDT)
"Mr. James W. Laferriere" <babydr@baby-dragons.com> wrote:

>  	Hello All ,  using ./configure ; make ,  bison seems to dislike the 
> subject matter .  Any further info just ask .  Insights welcome .
>  		Tia ,  JimL
> 
> gcc -D_GNU_SOURCE -O2 -Wstrict-prototypes -Wall -I../include -DRESOLVE_HOSTNAMES -DDESTDIR=\"/usr/\" -DCONFIG_GACT -DCONFIG_GACT_PROB   -c -o m_ematch.o m_ematch.c
> bison -d -t -v -o emp_ematch.yacc.c emp_ematch.y
> emp_ematch.y:11: unrecognized: %error-verbose
> emp_ematch.y:11:    Skipping to next %
> make[1]: *** [emp_ematch.yacc.c] Error 1
> make[1]: Leaving directory `/home/archive/iproute2-2.6.26/tc'
> make: *** [all] Error 2
> 

You need more recent version of bison (like 2.3).
