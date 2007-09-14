From: Dan Williams <dcbw@redhat.com>
Subject: Re: [git patches] net driver fixes
Date: Fri, 14 Sep 2007 14:31:17 -0400
Message-ID: <1189794677.2508.19.camel@xo-3E-67-34.localdomain>
References: <20070913053022.GA16891@havoc.gtf.org>
	 <1189793598.2508.4.camel@xo-3E-67-34.localdomain>
	 <46EAD049.4020107@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757461AbXINSct@vger.kernel.org>
In-Reply-To: <46EAD049.4020107@garzik.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-09-14 at 14:17 -0400, Jeff Garzik wrote:
> Dan Williams wrote:
> > WTF?  why would the default be to _not_ propagate carrier state?  Are
> > there some mitigating circumstances that require this driver to not
> > notify the stack of carrier on/off?  Userspace stuff really should know
> > about the carrier state, and this disables it by default.
> 
> 
> The commit explains that...

I admit that I probably don't understand the system architecture of
where ehea would be used, but would this
cause /sys/class/net/ethX/carrier to be TRUE even if the device has no
carrier?  That seems quite wrong IMHO.  When does ehea not have a
carrier?  And in that case, does sysfs say 1 or 0 for the carrier?

Dan
