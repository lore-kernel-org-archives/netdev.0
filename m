From: Michael-Luke Jones <mlj28@cam.ac.uk>
Subject: Re: [PATCH 3/3] Intel IXP4xx network drivers
Date: Mon, 7 May 2007 21:18:00 +0100
Message-ID: <33637217-BE44-4E03-A912-F4FE6E14AA6D@cam.ac.uk>
References: <m3abwhcy74.fsf@maximus.localdomain>
	<m3vef5biob.fsf@maximus.localdomain>
	<5BB7E1AB-5CE1-43C8-8CE3-E0DE0236BD09@cam.ac.uk>
	<m3hcqoa772.fsf@maximus.localdomain>
	<86D26EBE-5899-468F-9C79-23E83E0DE04B@cam.ac.uk>
	<m33b289zku.fsf@maximus.localdomain>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain;
	charset=US-ASCII;
	delsp=yes;
	format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>,
	ARM Linux Mailing List <linux-arm-kernel@lists.arm.linux.org.uk>,
	Russell King <rmk@arm.linux.org.uk>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk>
In-Reply-To: <m33b289zku.fsf@maximus.localdomain>
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

On 7 May 2007, at 20:57, Krzysztof Halasa wrote:

> Well, I'm told that (compatible) NPEs are present on other IXP CPUs.
> Not sure about details.

If, by a combined effort, we ever manage to create a generic NPE  
driver for the NPEs found in IXP42x/43x/46x/2000/23xx then the driver  
should go in arch/arm/npe.c

It's possible, but hard due to the differences in hardware design and  
the fact that boards based on anything other than 42x are few and far  
between. The vast majority of 'independent' users following mainline  
are likely running on 42x boards.

Thus, for now, I would drop the NPE / QMGR code in arch/arm/mach- 
ixp4xx/ and concentrate on making it 42x/43x/46x agnostic. One step  
at a time :)

Michael-Luke
-------------------------------------------------------------------
List admin: http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel
FAQ:        http://www.arm.linux.org.uk/mailinglists/faq.php
Etiquette:  http://www.arm.linux.org.uk/mailinglists/etiquette.php
