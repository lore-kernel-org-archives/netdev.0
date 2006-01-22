From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [2.6 patch] schedule SHAPER for removal
Date: Sun, 22 Jan 2006 19:32:56 +0100
Message-ID: <1137954776.3328.31.camel@laptopd505.fenrus.org>
References: <20060119021150.GC19398@stusta.de>
	 <20060119215722.GO16285@kvack.org> <20060121004848.GM31803@stusta.de>
	 <20060122174707.GC1008@kvack.org>  <20060122182034.GG10003@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Benjamin LaHaise <bcrl@kvack.org>, Andrew Morton <akpm@osdl.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>, jgarzik@pobox.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751311AbWAVSdI@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20060122182034.GG10003@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-01-22 at 19:20 +0100, Adrian Bunk wrote:
> On Sun, Jan 22, 2006 at 12:47:07PM -0500, Benjamin LaHaise wrote:
> > On Sat, Jan 21, 2006 at 01:48:48AM +0100, Adrian Bunk wrote:
> > > Do we really have to wait the three years between stable Debian releases 
> > > for removing an obsolete driver that has always been marked as 
> > > EXPERIMENTAL?
> > > 
> > > Please be serious.
> > 
> > I am completely serious.  The traditional cycle of obsolete code that works 
> > and is not causing a maintenence burden is 2 major releases -- one release 
> > during which the obsolete feature spews warnings on use, and another 
> > development cycle until it is actually removed.  That's at least 3 years, 
> > which is still pretty short compared to distro cycles.
> > 
> > There seems to be a lot of this disease of removing code for the sake of 
> > removal lately, and it's getting to the point of being really annoying.  If 
> > the maintainer of the code in question isn't pushing for its removal, I see 
> > no need to rush the process too much, especially when the affected users 
> > aren't even likely to see the feature being marked obsolete since they don't 
> > troll the source code looking for things that break setups.
> 
> The only supported combinations are distributions with the kernels they 
> ship.

I think you're being unreasonable here.

Removing unused code from the kernel, I'm all for that. Really.
But this is userspace visible functionality, and more care needs to be
taken than just adding a few lines to an obscure file in the kernel.
I agree with Ben that the kernel needs to printk a stern warning *AT USE
OF THE FEATURE* for at least a year before such a feature can be
removed. In addition I think that in case such a feature isn't actually
harmful of further development (for example, it could be because it's
fundamentally broken locking wise, or holding back major improvements)
then a longer period of warnings should be no problem. Together with
that should probably be something to ask distros to stop enabling the
feature asap, or at least communicate it as deprecated in their
respective release notes.
