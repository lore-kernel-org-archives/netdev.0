From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: kvm networking todo wiki
Date: Sun, 26 Sep 2010 13:21:12 +0200
Message-ID: <20100926112112.GB18408@redhat.com>
References: <20100921161124.GC22845@redhat.com>
 <4C9A873E.6010403@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Stevens <dlstevens@us.ibm.com>, sri@linux.vnet.ibm.com,
	Anthony Liguori <anthony@codemonkey.ws>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	Shirley Ma <mashirle@us.ibm.com>,
	"Xin, Xiaohui" <xiaohui.xin@intel.com>, jdike@linux.intel.com,
	herbert@gondor.hengli.com.au, lmr@redhat.com, akong@redhat.com,
	kvm@vger.kernel.org, qemu-devel@nongnu.org, netdev@vger.kernel.org
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4C9A873E.6010403@us.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 22, 2010 at 03:46:22PM -0700, Sridhar Samudrala wrote:
> On Tue, 2010-09-21 at 18:11 +0200, Michael S. Tsirkin wrote:
>=20
>     I've put up a wiki page with a kvm networking todo list,
>     mainly to avoid effort duplication, but also in the hope
>     to draw attention to what I think we should try addressing
>     in KVM:
>=20
>     http://www.linux-kvm.org/page/NetworkingTodo
>=20
>     This page could cover all networking related activity in KVM,
>     currently most info is related to virtio-net.
>=20
>     Note: if there's no developer listed for an item,
>     this just means I don't know of anyone actively working
>     on an issue at the moment, not that no one intends to.
>=20
>     I would appreciate it if others working on one of the items on th=
is list
>     would add their names so we can communicate better.  If others li=
ke this
>     wiki page, please go ahead and add stuff you are working on if an=
y.
>=20
>     It would be especially nice to add autotest projects:
>     there is just a short test matrix and a catch-all
>     'Cover test matrix with autotest', currently.
>=20
>     Currently there are some links to Red Hat bugzilla entries,
>     feel free to add links to other bugzillas.
>=20
>=20
> Thanks for capturing these items. It is really useful.
>=20
> Another item that is missing is
> - support assigning SR-IOV VF to a guest via tap/macvtap
>=20
> Currently, this requires
> =A0- VF to be put in promiscuous mode when using a bridge/tap
> =A0- add a new mac address to VF when using macvtap.
>=20
> I don't think any of the VF drivers provide these capabilities
> at this time.
>=20
> -Sridhar

I think this is part of what is needed for the work item:
    *  guest programmable mac/vlan filtering with macvtap=20
If yes pls add this detail if not add another item.
More importantly: anyone's going to work on this?


--=20
MST

