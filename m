From: "Lan, Tianyu" <tianyu.lan@intel.com>
Subject: Re: [RFC Patch 08/12] IXGBEVF: Rework code of finding the end transmit
 desc of package
Date: Sun, 25 Oct 2015 00:12:23 +0800
Message-ID: <562BADE7.4010105@intel.com>
References: <1445445464-5056-1-git-send-email-tianyu.lan@intel.com> <1445445464-5056-9-git-send-email-tianyu.lan@intel.com> <56280050.9020301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Alexander Duyck <alexander.duyck@gmail.com>, bhelgaas@google.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	eddie.dong@intel.com, nrupal.jani@intel.com,
	yang.z.zhang@intel.com, agraf@suse.de, kvm@vger.kernel.org,
	pbonzini@redhat.com, qemu-devel@nongnu.org,
	emil.s.tantilov@intel.com, intel-wired-lan@lists.osuosl.org,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, linux-kernel@vger.kernel.org,
	linux-pci@vger.kernel.org, matthew.vick@intel.com,
	mitch.a.williams@intel.com, netdev@vger.kernel.org,
	shannon.nelson@intel.com
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <56280050.9020301@gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 10/22/2015 5:14 AM, Alexander Duyck wrote:
> Where is i being initialized?  It was here but you removed it.  Are you
> using i without initializing it?

Sorry, the initialization was put into patch 10 by mistake. "i" is
assigned with "tx_ring->next_to_clean".
