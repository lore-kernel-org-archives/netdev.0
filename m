From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169, 2.6.2-rc2, Sager 4780 laptop
Date: Mon, 26 Jan 2004 23:55:59 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040126235559.A3832@electric-eye.fr.zoreil.com>
References: <Pine.LNX.4.58.0401261443190.7894@edp12.straus-frank.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: bhartin@straus-frank.com
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0401261443190.7894@edp12.straus-frank.int>; from bhartin@straus-frank.com on Mon, Jan 26, 2004 at 03:19:57PM -0600
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

bhartin@straus-frank.com <bhartin@straus-frank.com> :
[...]
> Attached is a tar.gz containing the outputs you request in your README, 
> plus 'lspci -v' output and my .config for the kernel.  This data was 
> collected from a fresh 2.6.2-rc2 bootup, using your full set of 2.6.2-rc1 
> patches, manually doing a 'modprobe r8169' once booted up.  The system is 
> running a P4 with HT enabled, with an SMP kernel.

There has been report of non-regression on non-SMP kernel with the following
patches applied (2.6.2-rc1 serie):
r8169-tx-index-overflow.patch
r8169-dma-api-tx.patch
r8169-dma-api-rx-buffers.patch
r8169-dma-api-tx-buffers.patch
r8169-rx_copybreak.patch
r8169-mac-phy-version.patch
r8169-init_one.patch
r8169-timer.patch
r8169-hw_start.patch
r8169-intr_mask.patch
r8169-suspend.patch
r8169-endianness.patch
r8169-getstats.patch

Can you confirm that the driver behaves the same as the standard driver
with a non-SMP enabled kernel ?

Does it make a difference if you give an 'acpi=off' option at boot time ?

r8169-addr-high.patch is not doing its job on amd64 so it is not suggested
to use it at all.

There is something broken wrt SMP and the r8169 patches: do not use both at
the same time. I still have to find what happens here.

--
Ueimor
