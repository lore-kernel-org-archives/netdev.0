From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [Qemu-devel] [RFC Patch 00/12] IXGBE: Add live migration support
 for SRIOV NIC
Date: Thu, 22 Oct 2015 15:55:34 +0300
Message-ID: <20151022155234-mutt-send-email-mst@redhat.com>
References: <1445445464-5056-1-git-send-email-tianyu.lan@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhelgaas@google.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, eddie.dong@intel.com,
	nrupal.jani@intel.com, yang.z.zhang@intel.com, agraf@suse.de,
	kvm@vger.kernel.org, pbonzini@redhat.com, qemu-devel@nongnu.org,
	emil.s.tantilov@intel.com, intel-wired-lan@lists.osuosl.org,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, linux-kernel@vger.kernel.org,
	linux-pci@vger.kernel.org, matthew.vick@intel.com,
	mitch.a.williams@intel.com, netdev@vger.kernel.org,
	shannon.nelson@intel.com
To: Lan Tianyu <tianyu.lan@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1445445464-5056-1-git-send-email-tianyu.lan@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 22, 2015 at 12:37:32AM +0800, Lan Tianyu wrote:
> This patchset is to propose a new solution to add live migration support for 82599
> SRIOV network card.
> 
> Im our solution, we prefer to put all device specific operation into VF and
> PF driver and make code in the Qemu more general.

Adding code to VF driver makes sense.  However, adding code to PF driver
is problematic: PF and VF run within different environments, you can't
assume PF and VF drivers are the same version.

I guess that would be acceptable if these messages make
it into the official intel spec, along with
hardware registers.

-- 
MST
