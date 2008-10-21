From: Bill Gatliff <bgat@billgatliff.com>
Subject: Re: [PATCH 14/16] RealView: Use the in-kernel smc911x.c driver	on
	RealView
Date: Tue, 21 Oct 2008 08:25:38 -0500
Message-ID: <48FDD852.7080104@billgatliff.com>
References: <OF6B543A5F.032D7BBC-ON802574E9.00340E58-802574E9.00396C6E@smsc.com>
	<1224585726.9330.22.camel@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Steve.Glendinning@smsc.com, Guennadi Liakhovetski <g.liakhovetski@gmx.de>,
	linux-arm-kernel@lists.arm.linux.org.uk, Ian.Saturley@smsc.com,
	netdev@vger.kernel.org
To: Catalin Marinas <catalin.marinas@arm.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk>
In-Reply-To: <1224585726.9330.22.camel@pc1117.cambridge.arm.com>
List-Unsubscribe: <http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=unsubscribe>
List-Archive: <http://lists.arm.linux.org.uk/lurker/list/linux-arm-kernel.html>
List-Post: <mailto:linux-arm-kernel@lists.arm.linux.org.uk>
List-Help: <mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=help>
List-Subscribe: <http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.arm.linux.org.uk
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk
List-Id: netdev.vger.kernel.org

Catalin Marinas wrote:
> On Tue, 2008-10-21 at 11:26 +0100, Steve.Glendinning@smsc.com wrote:
>> The smsc911x driver is still maintained (out of tree), and is used by many
>> of our customers.  Mainline inclusion is still very much the intention!
>>
>> Almost all the feedback I've had has been positive, but I've had a few
>> "can't you just fix the in-tree driver?" responses.  The trouble is it's
>> not a *small* piece of work!
> 
> Can we not have both drivers in the kernel until the transition to the
> new one has finished? We seem to still have both eepro100.c and e100.c
> in the kernel targeting similar chips.

I don't have a problem with that.  I have standardized my kernels on Steve's
driver, though, in anticipation of the transition.  So you know which one I'll
advocate for.  :)


b.g.
-- 
Bill Gatliff
bgat@billgatliff.com

-------------------------------------------------------------------
List admin: http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel
FAQ:        http://www.arm.linux.org.uk/mailinglists/faq.php
Etiquette:  http://www.arm.linux.org.uk/mailinglists/etiquette.php
