From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [1/6] 2.6.21-rc2: known regressions
Date: Mon, 05 Mar 2007 13:42:04 +0100
Message-ID: <1173098524.6638.19.camel@aeonflux.holtmann.net>
References: <Pine.LNX.4.64.0702272105220.12485@woody.linux-foundation.org>
	<20070305015031.GF3441@stusta.de> <45EB961D.6030808@rtr.ca>
	<20070305043443.GA29158@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Ayaz Abdulla <aabdulla@nvidia.com>, Pavel Machek <pavel@ucw.cz>,
   Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
   linux-pm@lists.osdl.org,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   Adrian Bunk <bunk@stusta.de>, bluez-devel@lists.sourceforge.net,
   maxk@qualcomm.com, Matt Mackall <mpm@selenic.com>, Mark Lord <lkml@rtr.ca>,
   Andrew Morton <akpm@linux-foundation.org>,
   Sid Boyce <g3vbv@blueyonder.co.uk>,
   Linus Torvalds <torvalds@linux-foundation.org>,
   Johannes Berg <johannes@sipsolutions.net>,
   Albert Hopkins <kernel@marduk.letterboxes.org>
To: Greg KH <greg@kroah.com>
Return-path: <linux-pm-bounces@lists.osdl.org>
In-Reply-To: <20070305043443.GA29158@kroah.com>
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/linux-pm>
List-Post: <mailto:linux-pm@lists.osdl.org>
List-Help: <mailto:linux-pm-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.osdl.org?subject=subscribe>
Sender: linux-pm-bounces@lists.osdl.org
Errors-To: linux-pm-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

Hi Greg,

> > >Subject    : Bluetooth RFComm locks up the machine  (device_move() rel=
ated)
> > >References : http://lkml.org/lkml/2007/3/4/64
> > >Submitter  : Mark Lord <lkml@rtr.ca>
> > >Caused-By  : Marcel Holtmann <marcel@holtmann.org>
> > >             commit c1a3313698895d8ad4760f98642007bf236af2e8
> > >Status     : unknown
> > =

> > A 2-line patch exists for fs/sysfs/dir.c to address this.
> > Waiting on Greg to apply it or substitute something prettier.  ;)
> =

> I want to see if Marcel agrees with it, as he did the original patch in
> that area.

I am not deep enough in the sysfs code to tell you if Mark's change it
correct or not. It looks however fully reasonable to me. From the higher
level perspective of the device_move() usage the RFCOMM code looks
correct and has been tested before I submitted it for inclusion.

Regards

Marcel
