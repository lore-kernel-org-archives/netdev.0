From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] netdev/phy: Handle IEEE802.3 clause 45 Ethernet
 PHYs
Date: Mon, 25 Jun 2012 16:50:51 -0700 (PDT)
Message-ID: <20120625.165051.1449022290472192376.davem@davemloft.net>
References: <4FE8F01B.2020207@gmail.com>
        <20120625.163355.2058784474741116830.davem@davemloft.net>
        <4FE8F8D8.1050009@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grant.likely@secretlab.ca, rob.herring@calxeda.com,
        devicetree-discuss@lists.ozlabs.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
        afleming@gmail.com, david.daney@cavium.com
To: ddaney.cavm@gmail.com
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <4FE8F8D8.1050009@gmail.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

From: David Daney <ddaney.cavm@gmail.com>
Date: Mon, 25 Jun 2012 16:48:40 -0700

> Therefore, I am going to propose that we add a 'flags' parameter to
> get_phy_device() and change the (two) callers.

Since there is only one flag, make it simply a bool for now.
