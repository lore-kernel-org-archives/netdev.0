From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [ofa-general] RE: [PATCH 11/13] QLogic VNIC: Driver utility
	file - implements various utility macros
Date: Thu, 1 May 2008 11:26:33 -0700
Message-ID: <20080501112633.7e272dcc@extreme>
References: <20080430171028.31725.86190.stgit@localhost.localdomain>
	<20080430172126.31725.48554.stgit@localhost.localdomain>
	<20080501075816.1010ec3a@extreme>
	<C07C40DB2364324799506DE8FF12F8D8590EE1@EPEXCH1.qlogic.org>
	<71d336490805011001he7359dfw831470986d87b385@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, "Amar
	Mudrankit \(Contractor - \)" <amar.mudrankit@qlogic.com>,
	general@lists.openfabrics.org, "Poornima Kamath \(Contractor
	- \)" <poornima.kamath@qlogic.com>
To: "Ramachandra K" <ramachandra.kuchimanchi@qlogic.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <71d336490805011001he7359dfw831470986d87b385@mail.gmail.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

On Thu, 1 May 2008 22:31:10 +0530
"Ramachandra K" <ramachandra.kuchimanchi@qlogic.com> wrote:

> Sorry for the resend. Original mail bounced from netdev.
> 
> On Thu, May 1, 2008 at 9:48 PM <ramachandra.kuchimanchi@qlogic.com> wrote:
> > Stephen,
> >
> >
> >  Stephen Hemminger [mailto:shemminger@vyatta.com] wrote:
> >
> >  > Ramachandra K <ramachandra.kuchimanchi@qlogic.com> wrote:
> >
> >  >> +#define is_power_of2(value) (((value) & ((value - 1))) == 0)
> >  >> +#define ALIGN_DOWN(x, a)    ((x)&(~((a)-1)))
> >
> >  > In kernel.h already
> >
> >  Will fix this. Thanks.
> >
> >
> >  >> +extern u32 vnic_debug;
> >
> >  > Use msg level macros instead?

There is a ethtool mechanism to set message level for debug method, read other
network drivers and look at netif_msg_timer(x), netif_msg_probe(x), etc in
include/linux/netdevice.h

The goal here is to not have any special configuration for each different type
of hardware.  It is bad user design to have each hardware vendor choosing different
mechanism and values to enable debugging. You can argue that the existing infrastructure
is inadequate, in which case extend the infrastructure for all devices.
