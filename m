From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFC net-next PATCH 1/4] pci: Add flag indicating device has been
 assigned by KVM
Date: Fri, 29 Jul 2011 21:00:42 -0700
Message-ID: <CAL3LdT4kvdnDRuybWj4_xah54asU1o-U7S3Ri7kbCA0qMgoKMg@mail.gmail.com>
References: <20110727221406.8435.44324.stgit@gitlad.jf.intel.com>
	<20110727221749.8435.19000.stgit@gitlad.jf.intel.com>
	<1311865877.24408.144.camel@cthulhu.hellion.org.uk>
	<43F901BD926A4E43B106BF17856F0755019414D525@orsmsx508.amr.corp.intel.com>
	<1311870459.24408.151.camel@cthulhu.hellion.org.uk>
	<43F901BD926A4E43B106BF17856F0755019414D59C@orsmsx508.amr.corp.intel.com>
	<20110729165446.GA6731@dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Rose, Gregory V" <gregory.v.rose@intel.com>,
	Ian Campbell <ijc@hellion.org.uk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20110729165446.GA6731@dumpdata.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 29, 2011 at 09:54, Konrad Rzeszutek Wilk
<konrad.wilk@oracle.com> wrote:
>> > > > On Wed, 2011-07-27 at 15:17 -0700, Greg Rose wrote:
>> > > > > Device drivers that create and destroy SR-IOV virtual functi=
ons via
>> > > > > calls to pci_enable_sriov() and pci_disable_sriov can cause
>> > catastrophic
>> > > > > failures if they attempt to destroy VFs while they are assig=
ned to
>> > > > > guest virtual machines. =C2=A0By adding a flag for use by th=
e KVM module
>> > > > > to indicate that a device is assigned a device driver can ch=
eck that
>> > > > > flag and avoid destroying VFs while they are assigned and av=
oid
>> > system
>> > > > > failures.
>> OK, but I hope Xen can still use the dev_flag assignment bit.
>
> Yeah, I think the attached patch would do it, but I need to double ch=
eck it.
> Do you have a git tree with this patchset?

Not yet, Greg was send these patches out as a RFC to make sure this
was the correct direction to go.

>
> Um, so you are fixing up ixgbe only - what about the cxgb4 and be dri=
ver?
> Shouldn't they also get some of this treatment?
>

Yes, Greg made changes to ixgbe to give an idea of what changes would
need to be made with the suggested changes.  From the feedback Greg
received, there is definite changes needed.  When Greg gets finished
with the necessary changes to the kernel/ethtool, we will have a
better idea of what changes are needed for the drivers.

--=20
Cheers,
Jeff
