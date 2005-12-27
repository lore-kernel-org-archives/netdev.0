From: Deepak Saxena <dsaxena@plexity.net>
Subject: Re: Integrating IXP4xx NPE support in kernel (with IXP4xx
	accesslibrary)
Date: Tue, 27 Dec 2005 15:11:07 -0800
Message-ID: <20051227231107.GC31728@plexity.net>
References: <20051220230806.619131000@localhost.localdomain>
	<20051224140752.GC9840@plexity.net>
	<20051224163653.GB18167@buici.com> <200512271054.39629.sr@denx.de>
	<1135691390.5818.99.camel@localhost.localdomain>
	<m3fyoek4yl.fsf@defiant.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, hadi@cyberus.ca,
	linux-arm-kernel@lists.arm.linux.org.uk
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk>
To: Krzysztof Halasa <khc@pm.waw.pl>
Content-Disposition: inline
In-Reply-To: <m3fyoek4yl.fsf@defiant.localdomain>
List-Unsubscribe: <http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=unsubscribe>
List-Archive: <http://lists.arm.linux.org.uk/pipermail/linux-arm-kernel>
List-Post: <mailto:linux-arm-kernel@lists.arm.linux.org.uk>
List-Help: <mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=help>
List-Subscribe: <http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.arm.linux.org.uk
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk
List-Id: netdev.vger.kernel.org

On Dec 27 2005, at 15:08, Krzysztof Halasa was caught saying:
> jamal <hadi@cyberus.ca> writes:
> 
> > No experience with the 4xx but some with the other intel NPs.
> > Is the driver a "dual stack" approach that Intel typically
> > has?
> 
> No, the Ethernet driver is Linux-only and uses the access library.
> Both are crap BTW, the library is much worse.
> 
> Actually I think the whole library needs to be rewritten from (almost)
> scratch (resulting in 5% or less code), and the Ethernet driver wouldn't
> be a problem then. The BSD-licensed version would of course help.
> 
> > Intel should be able to fund you to rewrite it - convincing them
> > they are going to sell more chips this way seems to be not too
> > hard, no?
> 
> Any Intel contacts interested? I could possibly earn some money as
> well :-)

Good luck. I've been working closely with Intel on the kernel side of the
IXP for 3 years now and the only business person in that division that 
understood the benefits of the going to GPL and how the Linux world works
is no longer there. From their point of view, it is simpler to have a single
codebase shared among VxWorks, WinCE, Linux, and QNX (?) than to have a 
separate Linux version.

~Deepak

-- 
Deepak Saxena - dsaxena@plexity.net - http://www.plexity.net

A starving child in Africa or you in front of your TV?
Where's the real tragedy?

-------------------------------------------------------------------
List admin: http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel
FAQ:        http://www.arm.linux.org.uk/mailinglists/faq.php
Etiquette:  http://www.arm.linux.org.uk/mailinglists/etiquette.php
