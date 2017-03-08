From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCHv3 net-next 21/22] net: mvpp2: set dma mask and coherent
 dma mask on PPv2.2
Date: Wed, 8 Mar 2017 11:00:10 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFE7A585@AcuExch.aculab.com>
References: <1488902000-2658-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1488902000-2658-22-git-send-email-thomas.petazzoni@free-electrons.com>
 <063D6719AE5E284EB5DD2968C1650D6DCFE79D2E@AcuExch.aculab.com>
 <20170307191201.645d23b4@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>,
 "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
 Yehuda Yitschak <yehuday@marvell.com>, Russell King <linux@arm.linux.org.uk>,
 Jason Cooper <jason@lakedaemon.net>, Pawel Moll <pawel.moll@arm.com>,
 Ian Campbell <ijc+devicetree@hellion.org.uk>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 Hanna Hawa <hannah@marvell.com>, Nadav
 Haklai <nadavh@marvell.com>, Rob Herring <robh+dt@kernel.org>,
 Andrew Lunn <andrew@lunn.ch>, Kumar Gala <galak@codeaurora.org>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Stefan Chulski <stefanc@marvell.com>, Marcin Wojtas <mw@semihalf.com>,
 "David S. Miller" <davem@davemloft.net>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: 'Thomas Petazzoni' <thomas.petazzoni@free-electrons.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170307191201.645d23b4@free-electrons.com>
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
> Sent: 07 March 2017 18:12
> Hello,
> 
> On Tue, 7 Mar 2017 17:24:21 +0000, David Laight wrote:
> 
> > Are the coherent mappings just used for ring structures?
> > If it might be reasonable to allocate them as a single entity,
> > thus guaranteeing they all reside in a single 4G region.
> 
> Do we have the guarantee that a DMA coherent allocation will not span a
> 4G boundary?

I'm pretty sure they are guaranteed not to cross any boundary they don't have to.
So a 16k buffer won't cross a 16k boundary.

	David
