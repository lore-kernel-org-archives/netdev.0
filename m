From: Amit Kucheria <amit.kucheria@nokia.com>
Subject: Re: [RFC] Runtime power management on	ipw2100
Date: Wed, 31 Jan 2007 13:53:20 +0200
Message-ID: <1170244400.6746.31.camel@amit-laptop>
References: <20070131075249.GA22115@srcf.ucam.org>
	<p731wlbphz3.fsf@bingen.suse.de> <20070131102744.GA24424@srcf.ucam.org>
	<200701311148.20777.ak@suse.de>
Reply-To: amit.kucheria@nokia.com
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Matthew Garrett <mjg59@srcf.ucam.org>, netdev@vger.kernel.org,
   linux-pm@lists.osdl.org, ipw2100-devel@lists.sourceforge.net
To: ext Andi Kleen <ak@suse.de>
Return-path: <linux-pm-bounces@lists.osdl.org>
In-Reply-To: <200701311148.20777.ak@suse.de>
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/linux-pm>
List-Post: <mailto:linux-pm@lists.osdl.org>
List-Help: <mailto:linux-pm-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.osdl.org?subject=subscribe>
Sender: linux-pm-bounces@lists.osdl.org
Errors-To: linux-pm-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-01-31 at 11:48 +0100, ext Andi Kleen wrote:
> On Wednesday 31 January 2007 11:27, Matthew Garrett wrote:
> > On Wed, Jan 31, 2007 at 12:13:04PM +0100, Andi Kleen wrote:
> > > Matthew Garrett <mjg59@srcf.ucam.org> writes:
> > > > =

> > > > PCI seems to require a delay of 10ms when sequencing from D3 to D0, =

> > > > which probably isn't acceptable latency for an "up" state.
> > > =

> > > It might be if the interface has been idle for some time
> > > (and the delay is not busy looping of course)
> > =

> > Hm. How would this interact with receiving packets?
> =

> The hardware will hopefully have support to wake itself up when that =

> happens.

Yes. Low power states without ability to respond to wakeup interrupts
would be broken behaviour generally.
