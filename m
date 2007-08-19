From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Marvell 88E8056 gigabit ethernet controller
Date: Sun, 19 Aug 2007 09:32:21 -0700
Message-ID: <20070819093221.4d3291e9@freepuppy.rosehill.hemminger.net>
References: <20070818121714.GA28247@1wt.eu>
	<283388.84897.qm@web38905.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Kevin E <kevin360@yahoo.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756530AbXHSQdQ@vger.kernel.org>
In-Reply-To: <283388.84897.qm@web38905.mail.mud.yahoo.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 18 Aug 2007 06:59:08 -0700 (PDT)
Kevin E <kevin360@yahoo.com> wrote:

> --- Willy Tarreau <w@1wt.eu> wrote:
> 
> > OK, in this trace, both controllers are on the same
> > bus. The broken
> > one has 'Capabilities: [100] Advanced Error
> > Reporting' the other
> > does not have, and the bridge to this bus has two
> > more capabilities :
> > 'Capabilities: [100] Virtual Channel' and
> > 'Capabilities: [180] Unknown (5)'.
> > 
> > I don't know whether it can jutify a different
> > behaviour. Also, maybe this
> > is caused by a minuscule difference in the BIOS
> > setup ?
> 

The working board has a different version of the Marvell chip:

$ grep Marvell working-MB 
04:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8056 PCI-E Gigabit Ethernet Controller (rev 14)
$ grep Marvell broken-MB 
04:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8056 PCI-E Gigabit Ethernet Controller (rev 12)

Not sure if that completely explains the problem because the broken chip on my
system is:
06:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8056 PCI-E Gigabit Ethernet Controller (rev 14)

I don't know what the differences are between versions.
