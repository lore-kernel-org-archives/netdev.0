From: Ian Campbell <ijc@hellion.org.uk>
Subject: Re: [net-next 1/8] pci: Add flag indicating device has been
 assigned by KVM
Date: Fri, 23 Sep 2011 08:27:46 +0100
Message-ID: <1316762872.23371.88.camel@zakaz.uk.xensource.com>
References: <1316599974-23205-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1316599974-23205-2-git-send-email-jeffrey.t.kirsher@intel.com>
	 <CAL3LdT7jDfytZD7WESmiHxvpmxKTEZ=uWRjzgsR9e4GtBPE31A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, linux-pci@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <CAL3LdT7jDfytZD7WESmiHxvpmxKTEZ=uWRjzgsR9e4GtBPE31A@mail.gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-09-22 at 21:16 -0700, Jeff Kirsher wrote:
> 
> 
> Jesse/Konrad/Ian-
> 
> I sent this patch out as part of a pull request for David Miller's
> net-next tree.  I know that Greg sent this originally out to the
> linux-pci mailing list as a RFC. Since Greg also has a patch against
> ixgbe which implemented this flag, I sent both patches for inclusion
> into David Miller's net-next.
> 
> Dave is wanting to ensure that the PCI maintainers have reviewed this
> and are ok with it before pulls my series of patches.

I'm not a PCI maintainer by any stretch of the imagination but FWIW this
change is fine by me.

My original reason for commenting on this patch was just to wonder
whether this would also be useful for Xen and I think the answer is we
should patch xen-pciback to use this new flag but I've not had time to
look into that.

I suppose by that measure the comment could be less KVM specific:
> +       /* Provide indication device is assigned by KVM */
> +       PCI_DEV_FLAGS_ASSIGNED = (__force pci_dev_flags_t) 4,

but that's not exactly a big deal.

I suppose really the flag indicates "VF in use" rather than necessarily
"assigned"? Would it be just as bad to have a VF driver in the host
active when the PF was unloaded?

Ian.

-- 
Ian Campbell
Current Noise: Mudhoney - Mudride (Live In Berlin)

Well, I think Perl should run faster than C.  :-)
		-- Larry Wall in <199801200306.TAA11638@wall.org>
