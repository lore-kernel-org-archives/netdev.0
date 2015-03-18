From: Shannon Nelson <shannon.nelson@intel.com>
Subject: Re: [Qemu-devel] PCI passthrough of 40G ethernet interface (Openstack/KVM)
Date: Wed, 18 Mar 2015 15:06:34 -0700
Message-ID: <CAP-MU4Pfv9W9FgaLxwOac3LnSJMxWcbYP4Pq43YjcJ9AWAamvQ@mail.gmail.com>
References: <CA+AkT2g=vFxKAUrHzWDxPzfq_SNvOUJvzHe5YsX+p+p6Ad8hog@mail.gmail.com>
	<jpg8uf2ghln.fsf@redhat.com>
	<CA+AkT2hZ5e=YRkSqQnpQm9CgfC_fqs-m_05FTRZQLt9ynj9A4w@mail.gmail.com>
	<jpgtwxpvk5x.fsf@redhat.com>
	<CA+AkT2j9UUTVmEsW1B4D_cvfCTjp-+62qhvnYxcrthy=QmQcaw@mail.gmail.com>
	<CA+AkT2gXouCdMWzRJBY0jYi6O61OjDnNf7XGnfLzhYkJCe00mg@mail.gmail.com>
	<jpg1tko7qwb.fsf@redhat.com>
	<CA+AkT2i2z+DGV0aezUQaOLKrVupprniuxC19xGOuNnd6gC1ZGg@mail.gmail.com>
	<jpglhiw4tal.fsf@redhat.com>
	<jpgk2yewcpt.fsf@redhat.com>
	<CA+AkT2g-Xt+hcpoh2ETx70v0mzV6m=-5zpxJrhs2C8WF--kmWw@mail.gmail.com>
	<CAP-MU4PSMMOv-sjfDtKOSaHa9-dy3cMovsHV7V_cV1k6N7yvFg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Bandan Das <bsd@redhat.com>,
	Alex Williamson <alex.williamson@redhat.com>,
	QEMU Developers <qemu-devel@nongnu.org>,
	kvm-devel <kvm@vger.kernel.org>,
	Stefan Assmann <sassmann@redhat.com>, netdev@vger.kernel.org
To: jacob jacob <opstkusr@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <CAP-MU4PSMMOv-sjfDtKOSaHa9-dy3cMovsHV7V_cV1k6N7yvFg@mail.gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 18, 2015 at 3:01 PM, Shannon Nelson
<shannon.nelson@intel.com> wrote:
>
>
> On Wed, Mar 18, 2015 at 8:40 AM, jacob jacob <opstkusr@gmail.com> wrote:
> >
> > On Wed, Mar 18, 2015 at 11:24 AM, Bandan Das <bsd@redhat.com> wrote:
> > >
> > > Actually, Stefan suggests that support for this card is still sketchy
> > > and your best bet is to try out net-next
> > > http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git
> > >
> > > Also, could you please post more information about your hardware setup
> > > (chipset/processor/firmware version on the card etc) ?
> >
> > Host CPU : Model name:            Intel(R) Xeon(R) CPU E5-2630 v2 @ 2.60GHz
> >
> > Manufacturer Part Number:  XL710QDA1BLK
> > Ethernet controller: Intel Corporation Ethernet Controller XL710 for
> > 40GbE QSFP+ (rev 01)
> >  #ethtool -i enp9s0
> > driver: i40e
> > version: 1.2.6-k
> > firmware-version: f4.22 a1.1 n04.24 e800013fd
> > bus-info: 0000:09:00.0
> > supports-statistics: yes
> > supports-test: yes
> > supports-eeprom-access: yes
> > supports-register-dump: yes
> > supports-priv-flags: no
> >

Jacob,

It looks like you're using a NIC with the e800013fd firmware from last
summer, and from a separate message that you saw these issues with
both the 1.2.2-k and the 1.2.37 version drivers.  I suggest the next
step would be to update the NIC firmware as there are some performance
and stability updates available that deal with similar issues.  Please
see the Intel Networking support webpage at
https://downloadcenter.intel.com/download/24769 and look for the
NVMUpdatePackage.zip.  This should take care of several of the things
Stefan might describe as "sketchy" :-).

sln
(Sent again, hopefully without gmail adding html and thereby getting
it blocked from the kernel mailing lists...)
