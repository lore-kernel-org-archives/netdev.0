From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC Patch 05/12] IXGBE: Add new sysfs interface
 of "notify_vf"
Date: Thu, 22 Oct 2015 15:51:51 +0300
Message-ID: <20151022155111-mutt-send-email-mst@redhat.com>
References: <1445445464-5056-1-git-send-email-tianyu.lan@intel.com>
	<1445445464-5056-6-git-send-email-tianyu.lan@intel.com>
	<5627FB20.3020003@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: emil.s.tantilov@intel.com, kvm@vger.kernel.org, linux-pci@vger.kernel.org,
	qemu-devel@nongnu.org, jesse.brandeburg@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	agraf@suse.de, matthew.vick@intel.com,
	intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
	yang.z.zhang@intel.com, mitch.a.williams@intel.com,
	nrupal.jani@intel.com, bhelgaas@google.com,
	Lan Tianyu <tianyu.lan@intel.com>, netdev@vger.kernel.org,
	shannon.nelson@intel.com, eddie.dong@intel.com,
	linux-kernel@vger.kernel.org, john.ronciak@intel.com, pbonzini@redhat.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
Content-Disposition: inline
In-Reply-To: <5627FB20.3020003@gmail.com>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: <http://lists.nongnu.org/archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 21, 2015 at 01:52:48PM -0700, Alexander Duyck wrote:
> Also have you even considered the MSI-X configuration on the VF?  I haven't
> seen anything anywhere that would have migrated the VF's MSI-X configuration
> from BAR 3 on one system to the new system.

Hypervisors do this for virtual devices so they can do this
for physical devices too.

-- 
MST
