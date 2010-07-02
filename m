From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [stable] [stable-2.6.32 PATCH] ixgbe: backport bug fix for tx
	panic
Date: Fri, 2 Jul 2010 14:37:13 -0700
Message-ID: <AANLkTimr7-8TIjuCjIbqrJSVH4VI-Pjp8plpjTubuTfE@mail.gmail.com>
References: <20100511004655.30590.74584.stgit@localhost.localdomain>
	<AANLkTinHm8ukQ3KlcrMKWvQ-QrlmBcWeVD-i99Q9Z7JL@mail.gmail.com>
	<alpine.WNT.2.00.1005250926320.2708@jbrandeb-desk1.amr.corp.intel.com>
	<20100525201837.GA13821@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"stable@kernel.org" <stable@kernel.org>,
	Brandon <brandon@ifup.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100525201837.GA13821@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 25, 2010 at 13:18, Greg KH <greg@kroah.com> wrote:
> On Tue, May 25, 2010 at 09:27:25AM -0700, Brandeburg, Jesse wrote:
>>
>>
>> On Tue, 25 May 2010, Jeff Kirsher wrote:
>>
>> > On Mon, May 10, 2010 at 17:46, Jeff Kirsher <jeffrey.t.kirsher@int=
el.com> wrote:
>> > > From: Jesse Brandeburg <jesse.brandeburg@intel.com>
>> > >
>> > > backporting this commit:
>> > >
>> > > commit fdd3d631cddad20ad9d3e1eb7dbf26825a8a121f
>> > > Author: Krishna Kumar <krkumar2@in.ibm.com>
>> > > Date: =C2=A0 Wed Feb 3 13:13:10 2010 +0000
>> > >
>> > > =C2=A0 =C2=A0ixgbe: Fix return of invalid txq
>> > >
>> > > =C2=A0 =C2=A0a developer had complained of getting lots of warni=
ngs:
>> > >
>> > > =C2=A0 =C2=A0"eth16 selects TX queue 98, but real number of TX q=
ueues is 64"
>> > >
>> > > =C2=A0 =C2=A0http://www.mail-archive.com/e1000-devel@lists.sourc=
eforge.net/msg02200.html
>> > >
>> > > =C2=A0 =C2=A0As there was no follow up on that bug, I am submitt=
ing this
>> > > =C2=A0 =C2=A0patch assuming that the other return points will no=
t return
>> > > =C2=A0 =C2=A0invalid txq's, and also that this fixes the bug (no=
t tested).
>> > >
>> > > =C2=A0 =C2=A0Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
>> > > =C2=A0 =C2=A0Signed-off-by: Jesse Brandeburg <jesse.brandeburg@i=
ntel.com>
>> > > =C2=A0 =C2=A0Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz=
=2Ejr@intel.com>
>> > > =C2=A0 =C2=A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@inte=
l.com>
>> > > =C2=A0 =C2=A0Signed-off-by: David S. Miller <davem@davemloft.net=
>
>> > >
>> > > CC: Brandon <brandon@ifup.org>
>> > > Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
>> > > ---
>> > >
>> > > =C2=A0drivers/net/ixgbe/ixgbe_main.c | =C2=A0 =C2=A08 ++++++--
>> > > =C2=A01 files changed, 6 insertions(+), 2 deletions(-)
>> > >
>> >
>> > Greg - status? =C2=A0Did you queue this patch for the stable relea=
se and I missed it?
>>
>> Maybe we didn't say (and we should have) that this fixes a panic on
>> machines with > 64 cores. =C2=A0Please apply to -stable 32.
>
> I'll get to it for the next release after this one, if that's ok.
>
> thanks,
>
> greg k-h
> --

I did not see this patch in the list of patches for the next release
of the stable kernel.  Just want to make sure this patch makes it this
time... :)

--=20
Cheers,
Jeff
