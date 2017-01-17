From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: ethernet: stmmac: add ARP management
Date: Tue, 17 Jan 2017 18:25:41 +0100
Message-ID: <20170117172541.GC9470@lunn.ch>
References: <1484672200-7755-1-git-send-email-christophe.roullier@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexandre Torgue <alexandre.torgue@st.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Christophe Roullier <christophe.roullier@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1484672200-7755-1-git-send-email-christophe.roullier@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 17, 2017 at 05:56:40PM +0100, Christophe Roullier wrote:
> DWC_ether_qos supports the Address Recognition

Resolution not Recognition? 

> Protocol (ARP) Offload for IPv4 packets. This feature
> allows the processing of the IPv4 ARP request packet
> in the receive path and generating corresponding ARP
> response packet in the transmit path. DWC_ether_qos
> generates the ARP reply packets for appropriate ARP
> request packets.

What about when .ndo_set_mac_address is called?

     Andrew
