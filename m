From: "Mr. James W. Laferriere" <babydr@baby-dragons.com>
Subject: Re: iproute2 2.6.22-070710 ,  mp_ematch.y:11: unrecognized:
 %error-verbose , ...
Date: Thu, 12 Jul 2007 20:58:00 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0707122055190.7098@filesrv1.baby-dragons.com>
References: <20070710190103.09ffa0e8@freepuppy.rosehill.hemminger.net>
 <Pine.LNX.4.64.0707112034250.9153@filesrv1.baby-dragons.com>
 <20070711211009.088c814e@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org, lartc@mailman.ds9a.nl
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns3.system-techniques.com ([204.91.156.41]:40819 "EHLO
	ns3.baby-dragons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752041AbXGMD6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 23:58:07 -0400
In-Reply-To: <20070711211009.088c814e@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 	Hello Stephen ,  Thank you .  see inline .

On Wed, 11 Jul 2007, Stephen Hemminger wrote:
> On Wed, 11 Jul 2007 20:38:43 -0700 (PDT)
> "Mr. James W. Laferriere" <babydr@baby-dragons.com> wrote:
>
>>  	Hello Stephen (& All) ,  Maybe next build of the tarball one could tar
>> up the base directory name as well .  ie: iproute2-2.6.22-070710/ .
>>  	The error below while being (quite probably) manually correctable isn't
>> something I'd expect to see in a release .
>>  		Twyl ,  JimL
>>
>> ps: I am not subscribed to netdev (I am quite sure) .
>>
>> $ ./configure
>> TC schedulers
>>   ATM    no
>>
>> $ make
>> make[1]: Entering directory `/home/archive/iproute2-2_6_22-070710/lib'
>> ...snip...
>> gcc -D_GNU_SOURCE -O2 -Wstrict-prototypes -Wall -I../include -DRESOLVE_HOSTNAMES -DCONFIG_GACT -DCONFIG_GACT_PROB   -c -o m_ematch.o m_ematch.c
>> bison -d -t -v -o emp_ematch.yacc.c emp_ematch.y
>> emp_ematch.y:11: unrecognized: %error-verbose
>> emp_ematch.y:11:    Skipping to next %
>> make[1]: *** [emp_ematch.yacc.c] Error 1
>> make[1]: Leaving directory `/home/archive/iproute2-2_6_22-070710/tc'
>> make: *** [all] Error 2
>> jiml@filesrv1:/home/archive
>
> Which version of bison. There have been issues where bison / flex don't
> always stay source compatible across releases.

$ bison --version
bison (GNU Bison) 1.35

$ flex --version
flex version 2.5.4

$ /usr/src/linux/scripts/ver_linux
If some fields are empty or look unusual you may have an old version.
Compare to the current minimal requirements in Documentation/Changes.

Linux filesrv1 2.6.18.3 #2 SMP Fri Jan 5 20:01:06 PST 2007 i686 unknown unknown GNU/Linux

Gnu C                  3.3.6
Gnu make               3.80
binutils               2.15.92.0.2
util-linux             2.12p
mount                  2.12p
module-init-tools      3.1
e2fsprogs              1.38
jfsutils               1.1.8
reiserfsprogs          3.6.19
xfsprogs               2.6.13
pcmcia-cs              3.2.8
quota-tools            3.12.
PPP                    2.4.4b1
nfs-utils              1.0.7
Linux C Library        2.3.5
Dynamic linker (ldd)   2.3.5
Linux C++ Library      5.0.7
Procps                 3.2.5
Net-tools              1.60
Kbd                    1.12
Sh-utils               5.2.1
udev                   064
Modules Loaded

 	Any thing else I can provide to help diagnose this please just ask .
 		Tia ,  JimL
-- 
+-----------------------------------------------------------------+
| James   W.   Laferriere | System   Techniques | Give me VMS     |
| Network        Engineer | 663  Beaumont  Blvd |  Give me Linux  |
| babydr@baby-dragons.com | Pacifica, CA. 94044 |   only  on  AXP |
+-----------------------------------------------------------------+
