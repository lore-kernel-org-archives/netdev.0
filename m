From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: stmmac: Add support for DWMAC5 with
 TSN features
Date: Wed, 01 Nov 2017 20:48:58 +0900 (KST)
Message-ID: <20171101.204858.1211893549464034006.davem@davemloft.net>
References: <859e8dd503b6368d4ec2ac2130cdeb88f48e2ae9.1509112414.git.joabreu@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Joao.Pinto@synopsys.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com
To: Jose.Abreu@synopsys.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <859e8dd503b6368d4ec2ac2130cdeb88f48e2ae9.1509112414.git.joabreu@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jose Abreu <Jose.Abreu@synopsys.com>
Date: Fri, 27 Oct 2017 14:55:44 +0100

> This adds support for IP version 5 of DWMAC. The new introduced
> features are the Enhancements to Scheduled Traffic (EST) as
> defined by IEEE802.1Qbv-2015 and Frame Preemption (FPE) as
> defined by IEEE802.1Qbu.
> 
> In order to not break previous setups all the necessary
> configuration is only performed when GMAC5 is detected and
> only when all the necessary parameters are available in the
> Device Tree.
> 
> EST:
> The IEEE802.1Qbv-2015 defines the schedule for each of the
> queues which makes the IP aware of traffic arrival time. This
> information can be used to block the lower priority traffic
> from transmission in this time window/slot.
> 
> FPE:
> The IEEE802.1Qbu defines a mechanism which breaks interfering
> frames into smaller fragments shuch that we have a more efficient
> use of network bandwidth. This needs EST enabled.
> 
> Signed-off-by: Jose Abreu <joabreu@synopsys.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Joao Pinto <jpinto@synopsys.com>
> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Cc: Alexandre Torgue <alexandre.torgue@st.com>
> ---
> Changes since v1:
> - Removed DT parsing

This patch is pointless until something is added which turns on the
boolean enable values.
