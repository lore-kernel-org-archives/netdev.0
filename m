From: Florin Malita <fmalita@gmail.com>
Subject: Re: [PATCH] channel bonding: add support for device-indexed
 parameters
Date: Tue, 27 Sep 2005 09:40:55 -0400
Message-ID: <20050927094055.7953a832.fmalita@gmail.com>
References: <20050927012444.be5d5311.fmalita@gmail.com>
	<200509270711.j8R7BunP014387@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: nsxfreddy@gmail.com, akpm@osdl.org, davem@davemloft.net,
	ctindel@users.sourceforge.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964939AbVI0NoV@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
In-Reply-To: <200509270711.j8R7BunP014387@death.nxdomain.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 27 Sep 2005 00:11:56 -0700
Jay Vosburgh <fubar@us.ibm.com> wrote:
> 
> Florin Malita <fmalita@gmail.com> wrote:
> [...]
> >How can you load a module multiple times on _any_ distro?
> 
> 	modprobe -obond0 bonding mode=your-favorite-mode
> 	modprobe -obond1 bonding mode=some-other-mode
> 
> 	and so on.  This is in the modprobe man page, and is described
> in the bonding documentation (found in the kernel documentation or at
> http://sourceforge.net/projects/bonding).  It is admittedly somewhat
> grotty, but it works.  

OK, I see this capability has been in module-init-tools since the 0.8
days. Doesn't apply to any 2.4/modutils based system tough.

> 
> >Not being able to set a (different) preferred
> >interface/primary for each bond device makes it unacceptable for
> >deployment in our environment.
> 
> 	How are you configuring bonding?  The current SuSE distros, for
> example, will do the multiple module load stuff automatically in the
> sysconfig scripts.  This is described in the current bonding
> documentation.

Our systems are RHEL3 based so unfortunately the naming trick above
doesn't work. 

But it does work on RHEL4 so admittedly, having this workaround
available for recent distros removes the urgency for a fix.

Thanks
Florin
