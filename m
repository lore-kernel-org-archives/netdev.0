From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Integrating IXP4xx NPE support in kernel (with IXP4xx
	accesslibrary)
Date: Wed, 21 Dec 2005 14:52:30 +0100
Message-ID: <20051221135230.GA22807@xi.wantstofly.org>
References: <20051220230806.619131000@localhost.localdomain>
	<200512211300.38163.sr@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk>
To: Stefan Roese <sr@denx.de>
Content-Disposition: inline
In-Reply-To: <200512211300.38163.sr@denx.de>
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

On Wed, Dec 21, 2005 at 01:00:34PM +0100, Stefan Roese wrote:

> The main question I have is, where should the IXP4xx access-library
> be located in the kernel directory structure?

Maybe you can explain to the list readers what it is and what it does?

If it's ixp4xx-specific, arch/arm/mach-ixp4xx might just be the best
place.  The ixp2000 microengine loader was put into arch/arm/mach-ixp2000
for mostly that reason (being ixp2000-specific), while the ethernet driver
that uses that microengine loader will live under drivers/net/.


> Please comment on this and let me know if such an effort has any chance
> of getting accepted into the official kernel.

Assuming that the license issues have all been worked out now, it'll
mostly depend on the quality of the code.  (If this is the same Intel
code that I saw a while ago, I think it'll need a fair amount of work
before it can go in.)


cheers,
Lennert

-------------------------------------------------------------------
List admin: http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel
FAQ:        http://www.arm.linux.org.uk/mailinglists/faq.php
Etiquette:  http://www.arm.linux.org.uk/mailinglists/etiquette.php
