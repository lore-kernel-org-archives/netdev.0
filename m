From: Amit Kucheria <amit.kucheria@nokia.com>
Subject: Re: [RFC] Runtime power management on ipw2100
Date: Wed, 31 Jan 2007 13:04:00 +0200
Message-ID: <1170241440.6746.27.camel@amit-laptop>
References: <20070131075249.GA22115@srcf.ucam.org>
	<1170234787.6746.22.camel@amit-laptop>
	<20070131094858.GA23842@srcf.ucam.org>
Reply-To: amit.kucheria@nokia.com
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: ipw2100-devel@lists.sourceforge.net, linux-pm@lists.osdl.org,
   netdev@vger.kernel.org
To: ext Matthew Garrett <mjg59@srcf.ucam.org>
Return-path: <linux-pm-bounces@lists.osdl.org>
In-Reply-To: <20070131094858.GA23842@srcf.ucam.org>
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

On Wed, 2007-01-31 at 09:48 +0000, ext Matthew Garrett wrote:
> On Wed, Jan 31, 2007 at 11:13:07AM +0200, Amit Kucheria wrote:
> =

> > What is the latency in changing between different PCI power states for
> > peripherals?
> =

> I'm not sure in the general case, but the power-down path for the =

> ipw2100 involves a static wait of 100ms in ipw2100_hw_stop_adapter(). =


Ouch!

<snip>

> PCI seems to require a delay of 10ms when sequencing from D3 to D0, =

> which probably isn't acceptable latency for an "up" state. While there's =


It might be acceptable to users who are just browsing the web, but not
to users who are streaming music from internet radio stations. IOW,
expose the interface (disabled by default) and leave policy to userspace
through a library.

> definitely a benefit to the sort of PM you're describing (it's a model =

> we've already started using on the desktop as far as the CPU goes), I =

> think we still want to be able to expose as much power saving as =

> possible.

I agree that this is a good start.

Regards,
Amit
