From: Bob Beers <bob.beers@gmail.com>
Subject: Re: wanPMC-CxT1E1
Date: Mon, 2 Nov 2009 15:41:44 -0500
Message-ID: <4f6ba3b0911021241gb6d9684ga76228013e0f5f14@mail.gmail.com>
References: <4f6ba3b0910261322j273c977fm356506c46f095832@mail.gmail.com>
	 <20091026204144.GA28436@kroah.com>
	 <4f6ba3b0910271048n10ff37fek9af191b133892e1e@mail.gmail.com>
	 <m3d4454phz.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg KH <greg@kroah.com>, Krzysztof Halasa <khc@pm.waw.pl>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:13110 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756806AbZKBUlk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 15:41:40 -0500
Received: by ey-out-2122.google.com with SMTP id d26so490384eyd.19
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2009 12:41:45 -0800 (PST)
In-Reply-To: <m3d4454phz.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 29, 2009 at 8:52 PM, Krzysztof Halasa <khc@pm.waw.pl> wrote=
:
> Bob Beers <bob.beers@gmail.com> writes:
>
>> ok, so where do I start, I have a system ready to start
>> =A0git cloning, and creating patches. I googled for a while
>> =A0but didn't find a nice recipe for participating in the -staging
>> =A0process.
>
> I gave it a try. At least compiles with few warnings. Not sure about =
the
> WORK_INIT() change.
>
> Created drivers/net/wan/cxt1e1, moved all relevant SBE's .c and .h
> there, added a simple Makefile/Kconfig. Quick and dirty. There is a
> _lot_ of work to be done before it meets the usual kernel standards.
>
> It's not in staging/ so the paths need to be corrected but I can't wo=
rk
> further on it at this time. Hand-edited but I tried to be careful.
>
<snip Krzysztof's diff file>

Ok, I took a shot at it too, It compiles for me and generates the
cxt1e1.ko file.
I have made a git clone of kernel, added the directory cxt1e1 under sta=
ging,
 added a Kconfig, Makefile, and all the *.[ch] from the tarball's drive=
r/ and
 include/ directories, called git add on cxt1e1 directory and the files
 mentioned above.  In the cxt1e1 directory I modified the *.[ch] files =
as I saw
 fit, and using many hints from Krzysztof
   (I'm also not sure about the changes to INIT_WORK).
 I modified Makefile in staging/ and ran 'git -a commit'.

Here is top part of output from 'git log --stat':

commit d54e08030785153c8c0f4eb4f1cf320d60fff286
Author: Bob Beers <bob.beers@gmail.com>
Date:   Mon Nov 2 15:06:19 2009 -0500

    Add CXT1E1 [1,2,4] channel wan card driver.

 drivers/net/wan/Makefile                     |    1 +
 drivers/staging/Kconfig                      |    2 +
 drivers/staging/Makefile                     |    1 +
 drivers/staging/cxt1e1/Kconfig               |   22 +
 drivers/staging/cxt1e1/Makefile              |   20 +
 drivers/staging/cxt1e1/comet.c               |  566 +++++++
 drivers/staging/cxt1e1/comet.h               |  366 +++++
 drivers/staging/cxt1e1/comet_tables.c        |  561 +++++++
 drivers/staging/cxt1e1/comet_tables.h        |   85 +
 drivers/staging/cxt1e1/functions.c           |  366 +++++
 drivers/staging/cxt1e1/hwprobe.c             |  400 +++++
 drivers/staging/cxt1e1/libsbew.h             |  581 +++++++
 drivers/staging/cxt1e1/linux.c               | 1354 ++++++++++++++++
 drivers/staging/cxt1e1/musycc.c              | 2180 ++++++++++++++++++=
++++++++
 drivers/staging/cxt1e1/musycc.h              |  460 ++++++
 drivers/staging/cxt1e1/ossiRelease.c         |   39 +
 drivers/staging/cxt1e1/pmc93x6_eeprom.c      |  559 +++++++
 drivers/staging/cxt1e1/pmc93x6_eeprom.h      |   60 +
 drivers/staging/cxt1e1/pmcc4.h               |  155 ++
 drivers/staging/cxt1e1/pmcc4_cpld.h          |  124 ++
 drivers/staging/cxt1e1/pmcc4_defs.h          |   82 +
 drivers/staging/cxt1e1/pmcc4_drv.c           | 1855 ++++++++++++++++++=
++++
 drivers/staging/cxt1e1/pmcc4_ioctls.h        |   81 +
 drivers/staging/cxt1e1/pmcc4_private.h       |  295 ++++
 drivers/staging/cxt1e1/pmcc4_sysdep.h        |   62 +
 drivers/staging/cxt1e1/sbe_bid.h             |   61 +
 drivers/staging/cxt1e1/sbe_promformat.h      |  157 ++
 drivers/staging/cxt1e1/sbecom_inline_linux.h |  310 ++++
 drivers/staging/cxt1e1/sbecrc.c              |  137 ++
 drivers/staging/cxt1e1/sbeid.c               |  217 +++
 drivers/staging/cxt1e1/sbeproc.c             |  358 +++++
 drivers/staging/cxt1e1/sbeproc.h             |   52 +
 drivers/staging/cxt1e1/sbew_ioc.h            |  136 ++
 33 files changed, 11705 insertions(+), 0 deletions(-)

How do I generate the patch file?

thanks,
--=20
-Bob Beers
