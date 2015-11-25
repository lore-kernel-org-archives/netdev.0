From: Lan Tianyu <tianyu.lan@intel.com>
Subject: Re: [RFC PATCH V2 0/3] IXGBE/VFIO: Add live migration support for
 SRIOV NIC
Date: Wed, 25 Nov 2015 16:21:44 +0800
Message-ID: <56556F98.5060507@intel.com>
References: <1448372298-28386-1-git-send-email-tianyu.lan@intel.com>	<5654722D.4010409@gmail.com>	<56552888.90108@intel.com> <CAKgT0UcSrewenfM2YdVojHFFqfK2aVbBN5LH8=BFzc1p0f9hvQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: a.motakis@virtualopensystems.com,
	Alex Williamson <alex.williamson@redhat.com>,
	b.reynal@virtualopensystems.com,
	Bjorn Helgaas <bhelgaas@google.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	eddie.dong@intel.com, nrupal.jani@intel.com,
	Alexander Graf <agraf@suse.de>, kvm@vger.kernel.org,
	Paolo Bonzini <pbonzini@redhat.com>, qemu-devel@nongnu.org,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	"Rustad, Mark D" <mark.d.rustad@intel.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Eric Auger <eric.auger@linaro.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	linux-api@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kerne
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKgT0UcSrewenfM2YdVojHFFqfK2aVbBN5LH8=BFzc1p0f9hvQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2015=E5=B9=B411=E6=9C=8825=E6=97=A5 13:30, Alexander Duyck wrote:
> No, what I am getting at is that you can't go around and modify the
> configuration space for every possible device out there.  This
> solution won't scale.


PCI config space regs are emulation by Qemu and so We can find the free
PCI config space regs for the faked PCI capability. Its position can be
not permanent.


>  If you instead moved the logic for notifying
> the device into a separate mechanism such as making it a part of the
> hot-plug logic then you only have to write the code once per OS in
> order to get the hot-plug capability to pause/resume the device.  Wha=
t
> I am talking about is not full hot-plug, but rather to extend the
> existing hot-plug in Qemu and the Linux kernel to support a
> "pause/resume" functionality.  The PCI hot-plug specification calls
> out the option of implementing something like this, but we don't
> currently have support for it.
>

Could you elaborate the part of PCI hot-plug specification you mentione=
d?

My concern is whether it needs to change PCI spec or not.



> I just feel doing it through PCI hot-plug messages will scale much
> better as you could likely make use of the power management
> suspend/resume calls to take care of most of the needed implementatio=
n
> details.
>=20
> - Alex
--=20
Best regards
Tianyu Lan
