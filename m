From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/7] Drop support for Renesys H8/300 architecture
Date: Fri, 30 Aug 2013 14:30:20 -0400 (EDT)
Message-ID: <20130830.143020.1246803952303746167.davem@davemloft.net>
References: <1377880842-6835-1-git-send-email-linux@roeck-us.net>
	<20130830165550.GA8151@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@roeck-us.net, linux-kernel@vger.kernel.org,
	linux-ide@vger.kernel.org, netdev@vger.kernel.org,
	linux-watchdog@vger.kernel.org, wim@iguana.be,
	viro@zeniv.linux.org.uk, eparis@redhat.com, jiang.liu@huawei.com,
	dhowells@redhat.com, tglx@linutronix.de, sfr@canb.auug.org.au,
	torvalds@linux-foundation.org
To: gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130830165550.GA8151@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 30 Aug 2013 09:55:50 -0700

> On Fri, Aug 30, 2013 at 09:40:35AM -0700, Guenter Roeck wrote:
>> H8/300 has been dead for several years, the kernel for it has
>> not compiled for ages, and recent versions of gcc for it are broken.
>> It is time to drop support for it.
>> 
>> Yes, I understand it is not that simple to drop an architecture,
>> and it may need some discussion, but someone has to put a stake
>> into the ground. Keeping a virtually dead architecture on life support
>> takes resources which are better spent elsewhere.
> 
> If this doesn't build, and no one is using it anymore, I agree, it
> should be removed.  If someone wants to revive it, 'git revert' works
> just fine.
> 
> You can put my:
> 
> Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> 
> on these patches, unless someone steps up to be the active maintainer of
> the arch and gets it building/working again.

I completely agree with Greg, and for the IDE and networking bits:

Acked-by: David S. Miller <davem@davemloft.net>
