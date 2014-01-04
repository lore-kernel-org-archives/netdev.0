From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: [net-next] pci_regs.h: Add PCI bus link speed and width defines
Date: Fri, 3 Jan 2014 17:00:42 -0700
Message-ID: <CAErSpo7TJXTCxpFKWXLTaHmqXXnYQdnpNeWt+cehSaES2Jh30w@mail.gmail.com>
References: <20140102.192133.1585340046080167370.davem@davemloft.net>
 <CAEuXFEw=A0mppxtgzpmnh3feLiKYb+LJQvFRMrW3C4h+jHpO2Q@mail.gmail.com>
 <CAErSpo7K3OBuTEZrXmhQ3iXtLf3M5JNnEqmAvaceroJ46VAOKg@mail.gmail.com> <20140103.185607.1380379872647540168.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: jesse.brandeburg@gmail.com,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	netdev <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	bjorn.helgaas@hp.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140103.185607.1380379872647540168.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 3, 2014 at 4:56 PM, David Miller <davem@davemloft.net> wrote:
> From: Bjorn Helgaas <bhelgaas@google.com>
> Date: Fri, 3 Jan 2014 15:15:57 -0700
>
>> However, I do raise my eyebrows a bit at drivers that poke around in
>> the PCIe capability.  I would prefer to have PCI core interfaces that
>> handle that instead.  But I haven't seen Jeff's changes yet.
>
> The changes just read the link status to interpret the speed at which
> the PCI-E link is running at.

Several drivers want to do that.  It'd be nice if somebody abstracted
that out somehow.  Jacob added pcie_get_minimum_link() which is
similar.  But maybe Jeff needs something more in this case.

In any case, it's not a blocker for this patch.

Bjorn
