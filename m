From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH v2 5/8] net: pxa168_eth: get and set the mac address on
 the Ethernet controller
Date: Tue, 9 Sep 2014 18:36:22 +0200
Message-ID: <20140909163622.GA28752@kwain>
References: <1410273848-24663-1-git-send-email-antoine.tenart@free-electrons.com>
 <1410273848-24663-6-git-send-email-antoine.tenart@free-electrons.com>
 <20140909162958.GS30828@titan.lakedaemon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: thomas.petazzoni@free-electrons.com, zmxu@marvell.com,
 devicetree@vger.kernel.org, netdev@vger.kernel.org,
 Antoine Tenart <antoine.tenart@free-electrons.com>,
 linux-kernel@vger.kernel.org, alexandre.belloni@free-electrons.com,
 jszhang@marvell.com, linux-arm-kernel@lists.infradead.org,
 sebastian.hesselbarth@gmail.com
To: Jason Cooper <jason@lakedaemon.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20140909162958.GS30828@titan.lakedaemon.net>
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

Jason,

On Tue, Sep 09, 2014 at 12:29:58PM -0400, Jason Cooper wrote:
> On Tue, Sep 09, 2014 at 04:44:05PM +0200, Antoine Tenart wrote:
> > When changing the MAC address, in addition to updating the dev_addr in
> > the net_device structure, this patch also update the MAC address
> > registers (high and low) of the Ethernet controller with the new MAC.
> > The address stored in these registers is used for IEEE 802.3x Ethernet
> > flow control, which is already enabled.
> > =

> > This patch also tries reading the MAC address stored in these registers
> > when probing the driver, to use the MAC address set by the bootloader
> > and avoid using a random one.
> =

> Hmm, the wording here seems odd.  I think the preference should be:
> =

>  1) bootloader-supplied addr via DT
>  2) addr read from device
>  3) randomly generated one.

I agree. I'll update that.

Antoine

-- =

Antoine T=E9nart, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
