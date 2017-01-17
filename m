From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: ethernet: stmmac: add ARP management
Date: Tue, 17 Jan 2017 09:41:44 -0800
Message-ID: <882b473a-233a-e27d-607c-b75729c5ec40@gmail.com>
References: <1484672200-7755-1-git-send-email-christophe.roullier@st.com>
 <20170117172541.GC9470@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Alexandre Torgue <alexandre.torgue@st.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
        Christophe Roullier <christophe.roullier@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170117172541.GC9470@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/17/2017 09:25 AM, Andrew Lunn wrote:
> On Tue, Jan 17, 2017 at 05:56:40PM +0100, Christophe Roullier wrote:
>> DWC_ether_qos supports the Address Recognition
> 
> Resolution not Recognition? 
> 
>> Protocol (ARP) Offload for IPv4 packets. This feature
>> allows the processing of the IPv4 ARP request packet
>> in the receive path and generating corresponding ARP
>> response packet in the transmit path. DWC_ether_qos
>> generates the ARP reply packets for appropriate ARP
>> request packets.
> 
> What about when .ndo_set_mac_address is called?

Was wondering about the same thing, but presumably, if there is correct
programming of the MAC address into the appropriate MAC address
registers, one could expect the hardware to latch that value while
generating the ARP replies?

While it sounds like this feature may be useful under heavy ARP spoofing
workloads, in practice, ARP packets are both small and infrequent, so
this sounds like micro optimization.
-- 
Florian
