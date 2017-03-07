From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCHv3 net-next 21/22] net: mvpp2: set dma mask and coherent
 dma mask on PPv2.2
Date: Tue, 7 Mar 2017 17:24:21 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFE79D2E@AcuExch.aculab.com>
References: <1488902000-2658-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1488902000-2658-22-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Yehuda Yitschak <yehuday@marvell.com>,
 Russell King <linux@arm.linux.org.uk>, Jason Cooper <jason@lakedaemon.net>,
 Hanna Hawa <hannah@marvell.com>, Nadav Haklai <nadavh@marvell.com>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Stefan Chulski <stefanc@marvell.com>, Marcin Wojtas <mw@semihalf.com>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: 'Thomas Petazzoni' <thomas.petazzoni@free-electrons.com>, "David S.
 Miller" <davem@davemloft.net>, "netdev@vger.kernel.org"
 <netdev@vger.kernel.org>, "devicetree@vger.kernel.org"
 <devicetree@vger.kernel.org>, Rob Herring <robh+dt@kernel.org>, Ian Campbell
 <ijc+devicetree@hellion.org.uk>, Pawel Moll <pawel.moll@arm.com>, "Mark
 Rutland" <mark.rutland@arm.com>, Kumar Gala <galak@codeaurora.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1488902000-2658-22-git-send-email-thomas.petazzoni@free-electrons.com>
Content-Language: en-US
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Thomas Petazzoni
> Sent: 07 March 2017 15:53
> On PPv2.2, the streaming mappings can be anywhere in the first 40 bits
> of the physical address space. However, for the coherent mappings, we
> still need them to be in the first 32 bits of the address space,
> because all BM pools share a single register to store the high 32 bits
> of the BM pool address, which means all BM pools must be allocated in
> the same 4GB memory area.

Are the coherent mappings just used for ring structures?
If it might be reasonable to allocate them as a single entity,
thus guaranteeing they all reside in a single 4G region.

	David
