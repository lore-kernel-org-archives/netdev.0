From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 3/3] netdev/of/phy: Add MDIO bus multiplexer driven
 by GPIO lines.
Date: Tue, 17 Apr 2012 22:53:08 -0400 (EDT)
Message-ID: <20120417.225308.1588669089502246200.davem@davemloft.net>
References: <1334683966-12112-1-git-send-email-ddaney.cavm@gmail.com>
        <1334683966-12112-4-git-send-email-ddaney.cavm@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grant.likely@secretlab.ca, rob.herring@calxeda.com,
        devicetree-discuss@lists.ozlabs.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
        afleming@gmail.com, galak@kernel.crashing.org,
        david.daney@cavium.com
To: ddaney.cavm@gmail.com
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1334683966-12112-4-git-send-email-ddaney.cavm@gmail.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

From: David Daney <ddaney.cavm@gmail.com>
Date: Tue, 17 Apr 2012 10:32:46 -0700

> From: David Daney <david.daney@cavium.com>
> 
> The GPIO pins select which sub bus is connected to the master.
> 
> Initially tested with an sn74cbtlv3253 switch device wired into the
> MDIO bus.
> 
> Signed-off-by: David Daney <david.daney@cavium.com>

Are you sure the Kconfig dependencies are sufficient?  This code seems
to depend upon OF, and in particular the OF_MDIO stuff.
