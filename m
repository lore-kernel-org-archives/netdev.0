From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC] Runtime power management on	ipw2100
Date: 31 Jan 2007 12:13:04 +0100
Message-ID: <p731wlbphz3.fsf@bingen.suse.de>
References: <20070131075249.GA22115@srcf.ucam.org>
	<1170234787.6746.22.camel@amit-laptop>
	<20070131094858.GA23842@srcf.ucam.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: ipw2100-devel@lists.sourceforge.net, netdev@vger.kernel.org,
   linux-pm@lists.osdl.org
To: Matthew Garrett <mjg59@srcf.ucam.org>
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

Matthew Garrett <mjg59@srcf.ucam.org> writes:
> =

> PCI seems to require a delay of 10ms when sequencing from D3 to D0, =

> which probably isn't acceptable latency for an "up" state.

It might be if the interface has been idle for some time
(and the delay is not busy looping of course)

How idle should be user configurable. =


But the idle detection needed for that should be probably higher =

up stack or at least some common library functions.

-Andi
