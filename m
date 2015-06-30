From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: mlx4: "failed to allocate default counter port 1"
Date: Tue, 30 Jun 2015 15:21:18 +0300
Message-ID: <CAJ3xEMgF+46tb0R2nbX8FYb2HBiFtn6Qzx61WCihBKTFbZFUtg@mail.gmail.com>
References: <alpine.LFD.2.11.1506301229520.1799@denkbrett>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eran Ben Elisha <eranbe@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: Sebastian Ott <sebott@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:34961 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753311AbbF3MVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2015 08:21:19 -0400
In-Reply-To: <alpine.LFD.2.11.1506301229520.1799@denkbrett>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 30, 2015 at 1:45 PM, Sebastian Ott
<sebott@linux.vnet.ibm.com> wrote:
> after the latest mellanox update the mlx4 driver fails to probe a VF:
> [   88.909562] mlx4_core 0000:00:00.0: mlx4_allocate_default_counters: failed to allocate default counter port 1 err -22
> [   88.909564] mlx4_core 0000:00:00.0: Failed to allocate default counters, aborting
> [   88.961735] mlx4_core: probe of 0000:00:00.0 failed with error -22
>
> PFs still work. See below for more dmesg output - I also added a line of
> debug output...maybe this helps.

Can you please send your "lspci | grep nox" listing? also what
Firmware version you have there? e.g when you probe the PF with
mlx4_core debug_level=1 can you sens us the lines that follow the PF
probe, e.g as here + dump of all caps as you did for the VF

  952.367911] mlx4_core: Mellanox ConnectX core driver v2.2-1 (Feb, 2014)
[  952.374606] mlx4_core: Initializing 0000:06:00.0
[  953.384332] mlx4_core 0000:06:00.0: FW version 2.34.5000 (cmd intf
rev 3), max commands 16
[...]

Also send us the output of "dmesg | grep -i counter" after such verbose load.

thanks,

Or.
