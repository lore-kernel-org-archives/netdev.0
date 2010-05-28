From: "Domsch, Matt" <Matt_Domsch@Dell.com>
Subject: Re: [PATCH 1/2] Export firmware assigned labels of network devices
 to sysfs
Date: Fri, 28 May 2010 08:16:30 -0500
Message-ID: <20100528131630.GA21575@mdomsch-pws380.aus.amer.dell.com>
References: <20100528115520.GA24114@littleblue.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-hotplug@vger.kernel.org" <linux-hotplug@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"Hargrave, Jordan" <Jordan_Hargrave@Dell.com>,
	"Rose, Charles" <Charles_Rose@Dell.com>,
	"Nijhawan, Vijay" <Vijay_Nijhawan@Dell.com>
To: "K, Narendra" <Narendra_K@Dell.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100528115520.GA24114@littleblue.us.dell.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 28, 2010 at 06:55:21AM -0500, K, Narendra wrote:
> Hello,
> 
> This patch is in continuation of an earlier discussion -
> 
> http://marc.info/?l=linux-netdev&m=126712978908314&w=3
> 
> The patch has the following review suggestions from the community incorporated -
> 
> 1. The name of the attribute has been changed from "smbiosname" to "label" to hide
> the implementation details.
> 2. The implementation has been moved to a new file drivers/pci/pci-label.c
> 
> The patch has following enhancements over the earlier patch -
> 
> 1.Implement support for ACPI _DSM(Device Specific Method) provided by
> the system firmware. The _DSM returns an index which is the instance number and
> a label assigned to the network device by the system firmware. The onboard devices
> will have lower indexes than the add-in devices. The patch exports both index and
> the label to sysfs.
> 
> For Example -
> 
> cat /sys/class/net/eth0/device/label
> Embedded Broadcom 5709C NIC 1
> 
> cat /sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0/index
> 1
> 
> Please refer to the PCI-SIG Draft ECN
> "PCIe Device Labeling under Operating Systems Draft ECN" at this link -
> http://www.pcisig.com/specifications/pciexpress/review_zone/.
> 
> It would be great to know your views on this ECN. Please let us know if you have
> have any suggestions or changes.

Please note: the 30-day review period for this Draft ECN ends on June
21, 2010.  If there are objections to this approach, or modifications
you believe are necessary, please raise them before this point so we
may adjust the draft before it is ratified.

Thanks,
Matt

-- 
Matt Domsch
Technology Strategist
Dell | Office of the CTO
