From: Deepak Saxena <dsaxena@plexity.net>
Subject: Re: Integrating IXP4xx NPE support in kernel (with IXP4xx
	accesslibrary)
Date: Tue, 27 Dec 2005 15:06:02 -0800
Message-ID: <20051227230602.GB31728@plexity.net>
References: <20051220230806.619131000@localhost.localdomain>
	<20051224140752.GC9840@plexity.net>
	<20051224163653.GB18167@buici.com> <200512271054.39629.sr@denx.de>
	<1135691390.5818.99.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1135691390.5818.99.camel@localhost.localdomain>
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

On Dec 27 2005, at 08:49, jamal was caught saying:
> A question for you: Does the 4XX allow you to rewrite the
> microcode? And if yes, why would you push this intel specific
> microcode?

No. The NPEs on the 4xx are not user-programmable like the uEngines.
You basically download the FW into the NPEs and they provide a "known"
interface that is accessible through Intel's software stack. We don't
want the FW in the kernel, we want the kernel interface, but we want
it written from scratch with none of the abstraction in the Intel code.

~Deepak

-- 
Deepak Saxena - dsaxena@plexity.net - http://www.plexity.net

A starving child in Africa or you in front of your TV?
Where's the real tragedy?

-------------------------------------------------------------------
List admin: http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel
FAQ:        http://www.arm.linux.org.uk/mailinglists/faq.php
Etiquette:  http://www.arm.linux.org.uk/mailinglists/etiquette.php
