From: Stephen Hemminger <shemminger@osdl.org>
Subject: Bug#396185: sky2 freezes in 2.6.17-2-686. Maintainer confirms that it should be fixed in 2.6.19-git tree.
Date: Mon, 18 Dec 2006 09:17:28 -0800
Message-ID: <20061218091728.2e1cf58b@freekitty>
References: <20061031073030.6658.11274.reportbug@kano.factory.vocord.ru>
	<20061031085716.GW13178@baikonur.stro.at>
	<20061031093051.GA3323@2ka.mipt.ru>
	<20061031093455.GX13178@baikonur.stro.at>
	<20061031094424.GA19052@2ka.mipt.ru>
	<20061116173532.GA10653@2ka.mipt.ru>
	<20061116093821.318efbe6@freekitty>
	<20061118112134.GI4213@nancy>
	<20061118112527.GA25624@2ka.mipt.ru>
	<20061129052948.GC13488@2ka.mipt.ru>
	<20061217141547.GA23387@2ka.mipt.ru>
Reply-To: Stephen Hemminger <shemminger@osdl.org>,
	396185@bugs.debian.org
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: maximilian attems <maks@sternwelten.at>, 396185@bugs.debian.org,
	netdev@vger.kernel.org
Return-path: <bounce-debian-bugs-dist=glddb-debian-bugs-dist=m.gmane.org@lists.debian.org>
Resent-Message-ID: <handler.396185.B396185.116646845821854@bugs.debian.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061217141547.GA23387@2ka.mipt.ru>
List-Post: <mailto:debian-bugs-dist@lists.debian.org>
List-Help: <mailto:debian-bugs-dist-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org

On Sun, 17 Dec 2006 17:15:47 +0300
Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:

> On Wed, Nov 29, 2006 at 08:29:48AM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> > > > > > > > > > > Here is link to discussion:
> > > > > > > > > > > http://marc.theaimsgroup.com/?l=linux-netdev&m=116227512815783&w=2
> > > > > > > > > > > 
> > > > > > > > > > 
> > > > > > > > > > can you try the linux-image 2.6.18, they are in unstable
> > > > > > > > > > and the etch release images.
> > > > > > 
> > > > > > 2.6.18-1-686 kernel still allows to freeze sky2.
> > > > > 
> > > > > Fix didn't go in until 2.6.18.2
> > > > 
> > > > fix is in the 2.6.18-2-686 linux image, you'd better update
> > > > your test box.
> > > 
> > > Just for clarification: there are at least two bugs described - one in
> > > the above link, and this new one. The former could only be fixed by
> > > reboot, the latter - by rmmod/modprobe sequence. The former had special
> > > info in dmesg, the latter does not.
> > > 
> > > Hopefully they both are fixed in 2.6.18-2.
> > > I will set it up as soon as time permits (it is my main desktop, which
> > > is rarely turned off) and report if problem still persists.
> > 
> > Bug still exists in 2.6.18-2 (package version 5).
> > Can be 'fixed' by rmmod/modprobe sequence though.
> > Is not easily reproducible.
> 
> Bug with freeze also exists in 2.6.18-3 (package version 2.6.18-7) - no
> messages in dmesg, no interrupts.
> It is dual lan board with only one port being used.
> rmmod/modprobe sequence brings NIC back to working mode.
> 

What are the statistics (ethtool -S eth0) after the hang.
One user reported a single pause frame being sent. I have can't reproduce
a hang with similar hardware, so am beginning to wonder if the problem is
pause negotiation, and interoperability problems??  Maybe the receiver gets
overloaded and sends one pause frame, but the switch can't really do flow
control and gets stuck.  I do stress tests with either a direct connect cable,
or with a switch that does flow control and lots of packets and see the driver/hardware
successfully doing flow control.




-- 
Stephen Hemminger <shemminger@osdl.org>
