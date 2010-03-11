From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/37] OF: move device node pointer into
	struct device.
Date: Thu, 11 Mar 2010 10:23:47 -0800 (PST)
Message-ID: <20100311.102347.169562565.davem@davemloft.net>
References: <20100311174830.4824.19820.stgit@angua>
	<20100311.102043.40590962.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, monstr@monstr.eu, broonie@opensource.wolfsonmicro.com,
	linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org,
	benh@kernel.crashing.org, devicetree-discuss@lists.ozlabs.org,
	gregkh@suse.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jeremy.kerr@canonical.com,
	linuxppc-dev@ozlabs.org, James.Bottomley@suse.de,
	linux-i2c@vger.kernel.org, ben-linux@fluff.org,
	microblaze-uclinux@itee.uq.edu.au, sparclinux@vger.kernel.org,
	akpm@linux-foundation.org, alsa-devel@alsa-project.org,
	jgarzik@pobox.com, dwmw2@infradead.org
To: grant.likely@secretlab.ca
Return-path: <alsa-devel-bounces@alsa-project.org>
In-Reply-To: <20100311.102043.40590962.davem@davemloft.net>
List-Unsubscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
	<mailto:alsa-devel-request@alsa-project.org?subject=unsubscribe>
List-Archive: <http://mailman.alsa-project.org/pipermail/alsa-devel>
List-Post: <mailto:alsa-devel@alsa-project.org>
List-Help: <mailto:alsa-devel-request@alsa-project.org?subject=help>
List-Subscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
	<mailto:alsa-devel-request@alsa-project.org?subject=subscribe>
Sender: alsa-devel-bounces@alsa-project.org
Errors-To: alsa-devel-bounces@alsa-project.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Thu, 11 Mar 2010 10:20:43 -0800 (PST)

> Three or four of the patches don't apply because only your tree
> has those "/* temporary */" comments, f.e. in arch/sparc/kernel/pci.c
> 
> I took care of this when applying to my tree.

It also doesn't build, what the heck is this against
Grant?

drivers/of/device.c: In function 'of_match_device':
drivers/of/device.c:24: error: 'const struct device' has no member named 'of_node'
drivers/of/device.c:26: error: 'const struct device' has no member named 'of_node'

Please make a patch set against Linus's vanilla tree so
I and others can test this.
