From: John Linn <John.Linn@xilinx.com>
Subject: RE: [PATCH] net: add Xilinx emac lite device driver
Date: Wed, 19 Aug 2009 01:20:48 -0600
Message-ID: <20090819072151.E2F681A0046@mail25-sin.bigfish.com>
References: <20090818153047.48E42ED8051@mail66-dub.bigfish.com>
	<20090818140418.347cb8ac@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michal Simek <michal.simek@petalogix.com>, netdev@vger.kernel.org,
	Sadanand Mutyala <sadanan@xilinx.com>, linuxppc-dev@ozlabs.org,
	jgarzik@pobox.com, davem@davemloft.net,
	John Williams <john.williams@petalogix.com>
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
Content-Class: urn:content-classes:message
In-Reply-To: <20090818140418.347cb8ac@nehalam>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Stephen Hemminger [mailto:shemminger@vyatta.com]
> Sent: Tuesday, August 18, 2009 10:04 PM
> To: John Linn
> Cc: netdev@vger.kernel.org; linuxppc-dev@ozlabs.org;
jgarzik@pobox.com; davem@davemloft.net; John
> Linn; grant.likely@secretlab.ca; Josh Boyer; John Williams; Michal
Simek; Sadanand Mutyala
> Subject: Re: [PATCH] net: add Xilinx emac lite device driver
> 
> On Tue, 18 Aug 2009 09:30:41 -0600
> John Linn <john.linn@xilinx.com> wrote:
> 
> > +/**
> > + * xemaclite_enable_interrupts - Enable the interrupts for the
EmacLite device
> > + * @drvdata:	Pointer to the Emaclite device private data
> > + *
> > + * This function enables the Tx and Rx interrupts for the Emaclite
device along
> > + * with the Global Interrupt Enable.
> > + */
> > +static void xemaclite_enable_interrupts(struct net_local *drvdata)
> 
> Docbook format is really a not necessary on local functions that
> are only used in the driver.  It is fine if you want to use it, as
> long as the file isn't processed by kernel make docs but
> the docbook is intended for automatic generation of kernel API
manuals.

Thanks, we realize that and have been consistent with our drivers in
that area. We aren't adding them to the make for the docs so it doesn't
seem like it should be a problem. 

> 
> --


This email and any attachments are intended for the sole use of the named recipient(s) and contain(s) confidential information that may be proprietary, privileged or copyrighted under applicable law. If you are not the intended recipient, do not read, copy, or forward this email message or any attachments. Delete this email message and any attachments immediately.
