From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] pci_regs.h: Add PCI bus link speed and width defines
Date: Fri, 03 Jan 2014 18:56:07 -0500 (EST)
Message-ID: <20140103.185607.1380379872647540168.davem@davemloft.net>
References: <20140102.192133.1585340046080167370.davem@davemloft.net>
	<CAEuXFEw=A0mppxtgzpmnh3feLiKYb+LJQvFRMrW3C4h+jHpO2Q@mail.gmail.com>
	<CAErSpo7K3OBuTEZrXmhQ3iXtLf3M5JNnEqmAvaceroJ46VAOKg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@gmail.com, linux-pci@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	linux-kernel@vger.kernel.org, bjorn.helgaas@hp.com
To: bhelgaas@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAErSpo7K3OBuTEZrXmhQ3iXtLf3M5JNnEqmAvaceroJ46VAOKg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bjorn Helgaas <bhelgaas@google.com>
Date: Fri, 3 Jan 2014 15:15:57 -0700

> However, I do raise my eyebrows a bit at drivers that poke around in
> the PCIe capability.  I would prefer to have PCI core interfaces that
> handle that instead.  But I haven't seen Jeff's changes yet.

The changes just read the link status to interpret the speed at which
the PCI-E link is running at.
