From: "Mr. James W. Laferriere" <babydr@baby-dragons.com>
Subject: re: iproute2 2.6.22-070710 ,  mp_ematch.y:11: unrecognized:
 %error-verbose , ...
Date: Wed, 11 Jul 2007 20:38:43 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0707112034250.9153@filesrv1.baby-dragons.com>
References: <20070710190103.09ffa0e8@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org, lartc@mailman.ds9a.nl
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns3.system-techniques.com ([204.91.156.41]:57294 "EHLO
	ns3.baby-dragons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750929AbXGLD4X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 23:56:23 -0400
In-Reply-To: <20070710190103.09ffa0e8@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 	Hello Stephen (& All) ,  Maybe next build of the tarball one could tar 
up the base directory name as well .  ie: iproute2-2.6.22-070710/ .
 	The error below while being (quite probably) manually correctable isn't 
something I'd expect to see in a release .
 		Twyl ,  JimL

ps: I am not subscribed to netdev (I am quite sure) .

$ ./configure
TC schedulers
  ATM    no

$ make
make[1]: Entering directory `/home/archive/iproute2-2_6_22-070710/lib'
...snip...
gcc -D_GNU_SOURCE -O2 -Wstrict-prototypes -Wall -I../include -DRESOLVE_HOSTNAMES -DCONFIG_GACT -DCONFIG_GACT_PROB   -c -o m_ematch.o m_ematch.c
bison -d -t -v -o emp_ematch.yacc.c emp_ematch.y
emp_ematch.y:11: unrecognized: %error-verbose
emp_ematch.y:11:    Skipping to next %
make[1]: *** [emp_ematch.yacc.c] Error 1
make[1]: Leaving directory `/home/archive/iproute2-2_6_22-070710/tc'
make: *** [all] Error 2
jiml@filesrv1:/home/archive


On Tue, 10 Jul 2007, Stephen Hemminger wrote:
> This is an update to iproute2 utilities including bug fixes and features
> related to 2.6.22 kernel.
>
> This package tries to be source compatible across releases.
> The same source should build on older systems, but obviously the
> newer kernel features won't be available.
>
> It can be downloaded from:
>  http://developer.osdl.org/dev/iproute2/download/iproute2-2.6.22-070710.tar.gz
>
> Repository:
>  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git
>
> For more info on iproute2 see:
>  http://linux-net.osdl.org/index.php/Iproute2
>
> Changelog
>
> David Lamparter (1):
>      iproute2: Format IPv6 tunnels endpoints nicely.
>
> Mike Frysinger (1):
>      ip/routef lifesaver
>
> Patrick McHardy (1):
>      Fwd: Re: more iproute2 issues (not critical)
>
> Pavel Roskin (1):
>      ip: add support for displaying link types 802 and 803
>
> Stephen Hemminger (11):
>      Revert "Increase internal clock resolution to nsec"
>      Add xt_tcpudp.h
>      incorrect initialization
>      headers update to 2.6.22
>      fix last change
>      fix build warnings
>      netem: static
>      Add TC_LIB_DIR environment variable.
>      ss: fix issues with signed inodes
>
> Thomas Graf (2):
>      iproute2: support for goto/nop action and detached flag
>      iproute2: Support IFF_LOWER_UP and IFF_DORMANT
>
> Yasuyuki KOZAKAI (1):
>      Fix symbolic link to tc-bfifo.8
>
> jamal (2):
>      SAD info
>      SPD info

-- 
+-----------------------------------------------------------------+
| James   W.   Laferriere | System   Techniques | Give me VMS     |
| Network        Engineer | 663  Beaumont  Blvd |  Give me Linux  |
| babydr@baby-dragons.com | Pacifica, CA. 94044 |   only  on  AXP |
+-----------------------------------------------------------------+
