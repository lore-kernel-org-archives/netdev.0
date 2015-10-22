From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [RFC Patch 00/12] IXGBE: Add live migration support for SRIOV NIC
Date: Thu, 22 Oct 2015 18:58:58 +0300
Message-ID: <CAJ3xEMhgzfbGf-3Z7GJGxg5VqbWGyKqoTt6c4C54sDNehdXVMg@mail.gmail.com>
References: <1445445464-5056-1-git-send-email-tianyu.lan@intel.com>
	<CAJ3xEMiStMJdGjgO9=MQrhLpBo8ZiTRoOL_P=aC9kyrNi91FSw@mail.gmail.com>
	<1445455227.4059.867.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Lan Tianyu <tianyu.lan@intel.com>,
	"Michael S. Tsirkin <mst@redhat.com> (mst@redhat.com)"
	<mst@redhat.com>, Bjorn Helgaas <bhelgaas@google.com>,
	carolyn.wyborny@intel.com,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	eddie.dong@intel.com, nrupal.jani@intel.com,
	yang.z.zhang@intel.com, Alexander Graf <agraf@suse.de>,
	kvm@vger.kernel.org, Paolo Bonzini <pbonzini@redhat.com>,
	qemu-devel@nongnu.org, emil.s.tantilov@intel.com,
	intel-wired-lan@lists.osuosl.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	john.ronciak@intel.com,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	linux-pci@vger.kernel.org, matthew.vick@intel.com,
	Mitch Williams <mitch.a.williams@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Shannon Nelson <shannon.nelson@intel.com>
To: Alex Williamson <alex.williamson@redhat.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1445455227.4059.867.camel@redhat.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 21, 2015 at 10:20 PM, Alex Williamson
<alex.williamson@redhat.com> wrote:

> This is why the typical VF agnostic approach here is to using bonding
> and fail over to a emulated device during migration, so performance
> suffers, but downtime is something acceptable.

bonding in the VM isn't a zero touch solution, right? is it really acceptable?
