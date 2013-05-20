From: Yinghai Lu <yinghai@kernel.org>
Subject: Re: [PATCH v2 6/7] PCI: Make sure VF's driver get attached after PF's
Date: Mon, 20 May 2013 09:01:58 -0700
Message-ID: <CAE9FiQWXQhbWObM=8wq+D84sbDakChyvuze9SS0SJxuxOUeQBQ@mail.gmail.com>
References: <1368586102-17661-1-git-send-email-yinghai@kernel.org>
	<20130515091248.00002fe3@unknown>
	<CAJZOPZ+L1QJdHePd_x9RAoqZKyJAKHo+hA8T1UZoe8=ozT98RA@mail.gmail.com>
	<519A1DFD.5080809@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Gu Zheng <guz.fnst@cn.fujitsu.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Yan Burman <yanb@mellanox.com>,
	Sathya Perla <Sathya.Perla@emulex.com>,
	NetDev <netdev@vger.kernel.org>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <519A1DFD.5080809@linux.intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 20, 2013 at 5:58 AM, Eliezer Tamir
<eliezer.tamir@linux.intel.com> wrote:
>>
> Maybe do the following:
> 1. split the VF PCI IDs into a separate PCI_ID device table.
> 2. have two pci_driver structs, one for all of the PF IDS and one with the
> VF IDS.
> 3. only register the first pci_driver struct from mlx4_init().
> 4. register the one for the VFs once your PFs are all up and ready.

that may help booting path that have driver built-in, or first time
load driver path.

For driver already loaded, and hotadd path, the problem is still there.

Yinghai
