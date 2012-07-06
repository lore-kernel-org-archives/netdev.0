From: Fengguang Wu <wfg@linux.intel.com>
Subject: Re: BUG: unable to handle kernel paging request at 00000000d8be176d
Date: Fri, 6 Jul 2012 15:52:45 +0800
Message-ID: <20120706075245.GA28521@localhost>
References: <20120705.142200.1828988382587831318.davem@davemloft.net>
 <20120706055859.GA27693@localhost>
 <1341555227.3265.54.camel@edumazet-glaptop>
 <20120705.234229.526162609862035833.davem@davemloft.net>
 <20120706073745.GA28197@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	steffen.klassert@secunet.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:45215 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751383Ab2GFHws (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2012 03:52:48 -0400
Content-Disposition: inline
In-Reply-To: <20120706073745.GA28197@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 06, 2012 at 03:37:45PM +0800, Fengguang Wu wrote:
> Hi David,
>=20
> > Fengguang Wu can I ask you politely not to quote the quilty patch i=
n
> > it's entirety when reporting bugs?  That screws up my workflow beca=
use
> > that patch goes then gets installed as a new patch in patchwork and=
 I
> > have to therefore tick it off every time you report a bug.
>=20
> Sorry for that!  Is it fine to _attach_ the referenced patch, or just
> a raw diff?  Or, the commit SHA and subject are all you want to see?

I used git-format-patch which makes a formal patch. How about git-show?
The output will be less like a formal patch, for example:

:       commit c5fb75aafab2fe31353b96cf556c1a689f8ac7e9
:       Author: Fengguang Wu <fengguang.wu@intel.com>
:       Date:   Thu Jun 14 22:36:29 2012 +0800

:           pms: fix build error in pms_probe()
:          =20
:           drivers/media/video/pms.c: In function =E2=80=98pms_probe=E2=
=80=99:
:           drivers/media/video/pms.c:1047:2: error: implicit declarati=
on of function =E2=80=98kzalloc=E2=80=99 [-Werror=3Dimplicit-function-d=
eclaration]
:           drivers/media/video/pms.c:1047:6: warning: assignment makes=
 pointer from integer without a cast [enabled by default]
:           drivers/media/video/pms.c:1116:2: error: implicit declarati=
on of function =E2=80=98kfree=E2=80=99 [-Werror=3Dimplicit-function-dec=
laration]
:          =20
:           Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>

:       diff --git a/drivers/media/video/pms.c b/drivers/media/video/pm=
s.c
:       index af2d908..77f9c92 100644
:       --- a/drivers/media/video/pms.c
:       +++ b/drivers/media/video/pms.c
:       @@ -26,6 +26,7 @@
:        #include <linux/fs.h>
:        #include <linux/kernel.h>
:        #include <linux/mm.h>
:       +#include <linux/slab.h>
:        #include <linux/ioport.h>
:        #include <linux/init.h>
:        #include <linux/mutex.h>

Thanks,
=46engguang
