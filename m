From: Kirby Bakken <kirbyb@us.ibm.com>
Subject: forcedeth HELP!
Date: Tue, 21 Sep 2004 16:22:03 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFAE924C89.3D2C8DEF-ON86256F16.0074991B-86256F16.007560A3@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="=_alternative 007560A086256F16_="
Cc: <c-d.hailfinger.kernel.2004@gmx.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multipart message in MIME format.
--=_alternative 007560A086256F16_=
Content-Type: text/plain; charset="US-ASCII"

Please excuse my ignorance...  and hopefully having done that, point me to 
the forum, mailing list, or whatever so I can figure this out (most likely 
with help....  )  :-)

I'm running a Nvidia Nforce2 MB (Biostar M7NCG 400).  When I boot with 
gentoo and a 2.4 kernel, eth0 works fine.  When I boot with a 2.6.7 
kernel, eth0 does not work.  When booted with the 2.6.7 kernel,  an 
'lsmod' shows forcedeth with a size of 12160, and a 'used by' of '0' (I'm 
so dumb, I'm not even sure if that means its just not used by anybody 
else, OR if the kernel isn't even using it, even though its loaded).

A look at /proc/net/dev is pretty much 0's, except for a 'drop' of 4 
bytes.... 

I've read that I can turn on 'generous' debug output by changing the #if 0 
in forcedeth.c from to a '1'...  But how then do I compile that?  A 'make 
forcedeth.o' produces a ton of errors....  And given that I CAN get that 
to compile,  where does the debug output show up.

Thanks in advance  :-)

=======================
Kirby Bakken
ESW Build Architect
Rochester, MN
email: kirbyb@us.ibm.com
ezpage:kirbyb
507-253-4549 / Tie:  553-4549
Fax:  507-253-3495

......one more straw can't possibly matter....

--=_alternative 007560A086256F16_=
Content-Type: text/html; charset="US-ASCII"


<br><font size=2 face="sans-serif">Please excuse my ignorance... &nbsp;and
hopefully having done that, point me to the forum, mailing list, or whatever
so I can figure this out (most likely with help.... &nbsp;) &nbsp;:-)</font>
<br>
<br><font size=2 face="sans-serif">I'm running a Nvidia Nforce2 MB (Biostar
M7NCG 400). &nbsp;When I boot with gentoo and a 2.4 kernel, eth0 works
fine. &nbsp;When I boot with a 2.6.7 kernel, eth0 does not work. &nbsp;When
booted with the 2.6.7 kernel, &nbsp;an 'lsmod' shows forcedeth with a size
of 12160, and a 'used by' of '0' (I'm so dumb, I'm not even sure if that
means its just not used by anybody else, OR if the kernel isn't even using
it, even though its loaded).</font>
<br>
<br><font size=2 face="sans-serif">A look at /proc/net/dev is pretty much
0's, except for a 'drop' of 4 bytes.... </font>
<br>
<br><font size=2 face="sans-serif">I've read that I can turn on 'generous'
debug output by changing the #if 0 in forcedeth.c from to a '1'... &nbsp;But
how then do I compile that? &nbsp;A 'make forcedeth.o' produces a ton of
errors.... &nbsp;And given that I CAN get that to compile, &nbsp;where
does the debug output show up.</font>
<br>
<br><font size=2 face="sans-serif">Thanks in advance &nbsp;:-)</font>
<br><font size=2 face="sans-serif"><br>
=======================<br>
Kirby Bakken<br>
ESW Build Architect<br>
Rochester, MN<br>
email: kirbyb@us.ibm.com<br>
ezpage:kirbyb<br>
507-253-4549 / Tie: &nbsp;553-4549<br>
Fax: &nbsp;507-253-3495<br>
<br>
......one more straw can't possibly matter....<br>
</font>
--=_alternative 007560A086256F16_=--
