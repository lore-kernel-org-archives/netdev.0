From: Pavel Machek <pavel@ucw.cz>
Subject: Re: hiberante hangs TCP Re: [EXAMPLE CODE] Parasite
 thread injection and TCP connection hijacking
Date: Fri, 17 Feb 2012 20:28:59 +0100
Message-ID: <20120217192859.GG2707@elf.ucw.cz>
References: <20110806121247.GC23937@htj.dyndns.org>
	<20111030044821.GA23741@spacedout.fries.net>
	<20111030201618.GA7696@google.com>
	<CAJ0PZbSRX6Rqn5NnnMkVGrPovtSuc2NWasysOYnjr3j9rON1VQ@mail.gmail.com>
	<20111102151039.GA12543@dhcp-172-17-108-109.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, linux-pm@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, David Fries <david@fries.net>
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-pm-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20111102151039.GA12543@dhcp-172-17-108-109.mtv.corp.google.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/linux-pm/>
List-Post: <mailto:linux-pm@lists.linux-foundation.org>
List-Help: <mailto:linux-pm-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=subscribe>
Sender: linux-pm-bounces@lists.linux-foundation.org
Errors-To: linux-pm-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Wed 2011-11-02 08:10:39, Tejun Heo wrote:
> Hello,
> =

> On Wed, Nov 02, 2011 at 06:44:31PM +0900, MyungJoo Ham wrote:
> > > Hmmm... sounds like taking down network interfaces before starting
> > > hibernation sequence should be enough, which shouldn't be too
> > > difficult to implement from userland. =A0Rafael, what do you think?
> > >
> > > Thanks.
> > =

> > Um... it seems that the "thaw" callbacks of network interfaces or TCP
> > should do something on this.
> > =

> > Probably, the "thaw" callbacks should make sure that the TCP
> > connections are closed?
> =

> I don't think it's a good idea to diddle with TCP connections from
> that layer.  From what I understand, it seem all we need is plugging
> tx/rx while preparing for hibernation.  That shouldn't be too
> difficult.

Yes, that should be done. =


If someone has uswsusp setup where they talk over the network, it
might break them, but hopefully noone is doing that.

Also hopefully noone does hibernation on /dev/nbd.

      	    							Pavel
-- =

(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html
