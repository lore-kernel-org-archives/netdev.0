From: Deepak Saxena <dsaxena@plexity.net>
Subject: Re: Integrating IXP4xx NPE support in kernel (with IXP4xx
	accesslibrary)
Date: Sat, 24 Dec 2005 06:04:06 -0800
Message-ID: <20051224140406.GB9840@plexity.net>
References: <20051220230806.619131000@localhost.localdomain>
	<200512211300.38163.sr@denx.de>
	<20051221135230.GA22807@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Content-Disposition: inline
In-Reply-To: <20051221135230.GA22807@xi.wantstofly.org>
List-Unsubscribe: <http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=unsubscribe>
List-Archive: <http://lists.arm.linux.org.uk/pipermail/linux-arm-kernel>
List-Post: <mailto:linux-arm-kernel@lists.arm.linux.org.uk>
List-Help: <mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=help>
List-Subscribe: <http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.arm.linux.org.uk
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk
List-Id: netdev.vger.kernel.org

On Dec 21 2005, at 14:52, Lennert Buytenhek was caught saying:
> On Wed, Dec 21, 2005 at 01:00:34PM +0100, Stefan Roese wrote:
> 
> > The main question I have is, where should the IXP4xx access-library
> > be located in the kernel directory structure?
> 
> Maybe you can explain to the list readers what it is and what it does?
> 
> If it's ixp4xx-specific, arch/arm/mach-ixp4xx might just be the best
> place.  The ixp2000 microengine loader was put into arch/arm/mach-ixp2000
> for mostly that reason (being ixp2000-specific), while the ethernet driver
> that uses that microengine loader will live under drivers/net/.

The access library is also used by the ixp2350 and will be used by next
generation Intel parts, so it needs to go somewhere common.
arch/arm/common or maybe drivers/net/ixp.

~Deepak

-- 
Deepak Saxena - dsaxena@plexity.net - http://www.plexity.net

A starving child in Africa or you in front of your TV?
Where's the real tragedy?

-------------------------------------------------------------------
List admin: http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel
FAQ:        http://www.arm.linux.org.uk/mailinglists/faq.php
Etiquette:  http://www.arm.linux.org.uk/mailinglists/etiquette.php
