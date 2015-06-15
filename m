From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 1/2] net: mvneta: introduce tx_csum_limit property
Date: Mon, 15 Jun 2015 15:36:01 +0100
Message-ID: <20150615143601.GM7557@n2100.arm.linux.org.uk>
References: <1434378443-23029-1-git-send-email-simon.guinot@sequanux.org>
 <1434378443-23029-2-git-send-email-simon.guinot@sequanux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	netdev@vger.kernel.org, stable@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Simon Guinot <simon.guinot@sequanux.org>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1434378443-23029-2-git-send-email-simon.guinot@sequanux.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 15, 2015 at 04:27:22PM +0200, Simon Guinot wrote:
> This patch introduces the tx_csum_limit DT property. This allows to
> configure the maximum frame size for which the Ethernet controller is
> able to perform TCP/IP checksumming. If MTU is set to a value greater
> than tx_csum_limit, then the features NETIF_F_IP_CSUM and NETIF_F_TSO
> are disabled.
> 
> Signed-off-by: Simon Guinot <simon.guinot@sequanux.org>
> Cc: <stable@vger.kernel.org> # v3.8+

Sorry, I just tripped over this.  This looks like a patch adding a new
_feature_ to this ethernet driver.  It isn't a regression fix, and it
isn't a bug fix.  Why are you wanting to get it into stable kernels,
which are supposed to only have bug and regression fixes applied?

-- 
FTTC broadband for 0.8mile line: currently at 10.5Mbps down 400kbps up
according to speedtest.net.
