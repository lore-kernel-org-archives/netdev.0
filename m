From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [PATCH v4 06/12] ARM: dove: add gigabit ethernet and mvmdio
 device tree nodes
Date: Wed, 22 May 2013 14:49:36 -0400
Message-ID: <20130522184936.GK31290@titan.lakedaemon.net>
References: <519C9333.20609@gmail.com> <519C9822.9040909@windriver.com>
 <519C9A66.3050807@gmail.com>
 <20130522131010.GB31290@titan.lakedaemon.net>
 <20130522165908.GB12320@obsidianresearch.com>
 <519D0143.1000203@gmail.com>
 <20130522173505.GH31290@titan.lakedaemon.net>
 <519D038C.9000605@gmail.com>
 <20130522174815.GI31290@titan.lakedaemon.net>
 <519D1204.4090701@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org,
 Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
 "tiejun.chen" <tiejun.chen@windriver.com>,
 Lennert Buytenhek <buytenh@wantstofly.org>, linuxppc-dev@lists.ozlabs.org,
 David Miller <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <519D1204.4090701@gmail.com>
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

On Wed, May 22, 2013 at 08:44:20PM +0200, Sebastian Hesselbarth wrote:
> On 05/22/2013 07:48 PM, Jason Cooper wrote:
> >On Wed, May 22, 2013 at 07:42:36PM +0200, Sebastian Hesselbarth wrote:
> >>Hmm, maybe a little bit too early. While restoring the MAC address now
> >>works, another bug arises which I guess is related with phy setup
> >>and aneg.
> >>
> >>Will investigate and update patch set accordingly.
> >
> >Cool, chances are, we should be able to take that patch in by itself for
> >this merge window...
> 
> Which patch do you mean? The local-mac-address workaround will only be
> available for DT mv643xx_eth because it uses the DT node to store the
> MAC.

I thought you were replacing the unconditional ethernet clock grabbing
with reading the mac from the registers and updating the dtb?  In
mach-kirkwood/board-dt.c?

confused. :-/

Jason.
