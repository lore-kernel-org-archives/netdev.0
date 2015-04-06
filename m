From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: dsa: fix filling routing table from OF
 description
Date: Mon, 06 Apr 2015 17:31:59 -0400 (EDT)
Message-ID: <20150406.173159.204611711817722389.davem@davemloft.net>
References: <1516684.D2TdrA1BPT@kuro.zhome>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com, grant.likely@linaro.org,
	robh+dt@kernel.org, f.fainelli@gmail.com, fabf@skynet.be,
	linux-kernel@vger.kernel.org
To: pavel.nakonechny@skitlab.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1516684.D2TdrA1BPT@kuro.zhome>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Nakonechny <pavel.nakonechny@skitlab.ru>
Date: Sun, 05 Apr 2015 00:46:21 +0300

> According to description in 'include/net/dsa.h', in cascade switches
> configurations where there are more than one interconnected devices,
> 'rtable' array in 'dsa_chip_data' structure is used to indicate which
> port on this switch should be used to send packets to that are destined
> for corresponding switch.
> 
> However, dsa_of_setup_routing_table() fills 'rtable' with port numbers
> of the _target_ switch, but not current one.
> 
> This commit removes redundant devicetree parsing and adds needed port
> number as a function argument. So dsa_of_setup_routing_table() now just
> looks for target switch number by parsing parent of 'link' device node.
> 
> To remove possible misunderstandings with the way of determining target
> switch number, a corresponding comment was added to the source code and
> to the DSA device tree bindings documentation file.
> 
> This was tested on a custom board with two Marvell 88E6095 switches with
> following corresponding routing tables: { -1, 10 } and { 8, -1 }.
> 
> Signed-off-by: Pavel Nakonechny <pavel.nakonechny@skitlab.ru>
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Applied, thanks.
