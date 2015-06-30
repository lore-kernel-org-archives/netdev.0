From: Sebastian Ott <sebott@linux.vnet.ibm.com>
Subject: Re: mlx4: "failed to allocate default counter port 1"
Date: Tue, 30 Jun 2015 15:19:42 +0200 (CEST)
Message-ID: <alpine.LFD.2.11.1506301505320.1799@denkbrett>
References: <alpine.LFD.2.11.1506301229520.1799@denkbrett>  <CAJ3xEMgF+46tb0R2nbX8FYb2HBiFtn6Qzx61WCihBKTFbZFUtg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eran Ben Elisha <eranbe@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAJ3xEMgF+46tb0R2nbX8FYb2HBiFtn6Qzx61WCihBKTFbZFUtg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 30 Jun 2015, Or Gerlitz wrote:
> On Tue, Jun 30, 2015 at 1:45 PM, Sebastian Ott
> <sebott@linux.vnet.ibm.com> wrote:
> > after the latest mellanox update the mlx4 driver fails to probe a VF:
> > [   88.909562] mlx4_core 0000:00:00.0: mlx4_allocate_default_counters: failed to allocate default counter port 1 err -22
> > [   88.909564] mlx4_core 0000:00:00.0: Failed to allocate default counters, aborting
> > [   88.961735] mlx4_core: probe of 0000:00:00.0 failed with error -22
> >
> > PFs still work. See below for more dmesg output - I also added a line of
> > debug output...maybe this helps.
> 
> Can you please send your "lspci | grep nox" listing? also what

0000:00:00.0 Ethernet controller: Mellanox Technologies MT27500 Family [ConnectX-3 Virtual Function]

> Firmware version you have there? e.g when you probe the PF with
> mlx4_core debug_level=1 can you sens us the lines that follow the PF
> probe, e.g as here + dump of all caps as you did for the VF

I have access to 2 machines and run a guest instance on both machines:
* on one the guest has acccess to a PF, but VF enablement is disallowed
* on the other the hypervisor controls the PF and the guests have only
  access to the VFs - so I cannot say much about the PF here

At least I found out the FW version - it's: 2.33.5100

Regards,
Sebastian

> 
>   952.367911] mlx4_core: Mellanox ConnectX core driver v2.2-1 (Feb, 2014)
> [  952.374606] mlx4_core: Initializing 0000:06:00.0
> [  953.384332] mlx4_core 0000:06:00.0: FW version 2.34.5000 (cmd intf
> rev 3), max commands 16
> [...]
> 
> Also send us the output of "dmesg | grep -i counter" after such verbose load.
> 
> thanks,
> 
> Or.
> 
> 
