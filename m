From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: GigE on PowerMac G5
Date: Tue, 07 Mar 2006 00:15:06 +1100
Message-ID: <1141650907.11221.61.camel@localhost.localdomain>
References: <jebqwmfeh9.fsf@sykes.suse.de>
	<1141507000.17127.4.camel@localhost.localdomain>
	<jefylvzwhw.fsf@sykes.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc64-dev@ozlabs.org
Return-path: <linuxppc64-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: Andreas Schwab <schwab@suse.de>
In-Reply-To: <jefylvzwhw.fsf@sykes.suse.de>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc64-dev>
List-Post: <mailto:linuxppc64-dev@ozlabs.org>
List-Help: <mailto:linuxppc64-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc64-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc64-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-03-06 at 11:40 +0100, Andreas Schwab wrote:
> Benjamin Herrenschmidt <benh@kernel.crashing.org> writes:
> 
> > On Sat, 2006-03-04 at 15:53 +0100, Andreas Schwab wrote:
> >> I suppose the NIC in the PowerMac G5 can do GigE, yet when plugged into a
> >> GB switch it is only willing to talk 100MB with it.  Any idea why?  Kernel
> >> is 2.6.16-rc5-git2.
> >
> > Works for me... Must be a problem with auto-neg and your switch, or the
> > cable.... Can you check how the switch is configured maybe ? You can
> > also try forcing the link speed with ethtool.
> 
> It's not the cable, I have swapped it with another system where Gb is
> working fine.  Neither it's the switch port, I have swapped it too.  I
> can't force the speed with ethtool either.  Any other idea what to look
> for?

At this point, all I can say is... does it work in OS X ?

Ben.
