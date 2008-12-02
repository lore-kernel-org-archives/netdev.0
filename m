From: Yu Zhao <yu.zhao@intel.com>
Subject: [SR-IOV driver example 0/3 resend] introduction
Date: Tue, 2 Dec 2008 17:27:41 +0800
Message-ID: <20081202092741.GA1859@yzhao12-linux.sh.intel.com>
References: <20081121183605.GA7810@yzhao12-linux.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "greg@kroah.com" <greg@kroah.com>,
	"matthew@wil.cx" <matthew@wil.cx>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	netdev@vger.kernel.org, jun.nakajima@intel.com,
	gregory.v.rose@intel.com
To: "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081121183605.GA7810@yzhao12-linux.sh.intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

SR-IOV drivers of Intel 82576 NIC are available. There are two parts
of the drivers: Physical Function driver and Virtual Function driver.
The PF driver is based on the IGB driver and is used to control PF to
allocate hardware specific resources and interface with the SR-IOV core.
The VF driver is a new NIC driver that is same as the traditional PCI
device driver. It works in both the host and the guest (Xen and KVM)
environment.

These two drivers are testing versions and they are *only* intended to
show how to use SR-IOV API.

Intel 82576 NIC specification can be found at:
http://download.intel.com/design/network/datashts/82576_Datasheet_v2p1.pdf

[SR-IOV driver example 0/3 resend] introduction
[SR-IOV driver example 1/3 resend] PF driver: hardware specific operations
[SR-IOV driver example 2/3 resend] PF driver: integrate with SR-IOV core
[SR-IOV driver example 3/3 resend] VF driver: an independent PCI NIC driver
