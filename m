From: Frans Pop <elendil@planet.nl>
Subject: Re: [2.6.30] e1000e: pci_enable_pcie_error_reporting
	failed 0xfffffffb
Date: Thu, 21 May 2009 22:00:13 +0200
Message-ID: <200905212200.14375.elendil@planet.nl>
References: <200905141312.35945.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, linux-pm@lists.linux-foundation.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>, linux-kernel@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Netdev <netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <200905141312.35945.elendil@planet.nl>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Thursday 14 May 2009, Frans Pop wrote:
> With 2.6.30-rc[45] I'm always seeing this error while resuming from STR
> on my HP 2510p notebook:
>
>   e1000e 0000:00:19.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
> ! e1000e 0000:00:19.0: pci_enable_pcie_error_reporting failed 0xfffffffb
>   e1000e 0000:00:19.0: setting latency timer to 64 
>   e1000e 0000:00:19.0: wake-up capability disabled by ACPI
>   e1000e 0000:00:19.0: PME# disabled
>   e1000e 0000:00:19.0: wake-up capability disabled by ACPI
>   e1000e 0000:00:19.0: PME# disabled
>   e1000e 0000:00:19.0: irq 26 for MSI/MSI-X
>
> The error only shows up during resume, not during normal boot.
>
> With 2.6.29 the error is not present. Is this something that should be
> looked into? Networking still comes up normally.

I'm still seeing this with 2.6.30-rc6. Should I just ignore it or is it an
indication of a problem/regression?

Cheers,
FJP

------------------------------------------------------------------------------
Register Now for Creativity and Technology (CaT), June 3rd, NYC. CaT
is a gathering of tech-side developers & brand creativity professionals. Meet
the minds behind Google Creative Lab, Visual Complexity, Processing, & 
iPhoneDevCamp asthey present alongside digital heavyweights like Barbarian
Group, R/GA, & Big Spaceship. http://www.creativitycat.com 
