From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [RFC] [PATCH 0/3] ioat: DMA engine support
Date: Fri, 9 Dec 2005 10:12:28 +0300
Message-ID: <20051209071228.GB19920@2ka.mipt.ru>
References: <4384F3AD.4080105@pobox.com> <Pine.LNX.4.44.0512081606060.24134-100000@gate.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Andrew Grover <andrew.grover@intel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	john.ronciak@intel.com, christopher.leech@intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932269AbVLIHMm@vger.kernel.org>
To: Kumar Gala <galak@gate.crashing.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0512081606060.24134-100000@gate.crashing.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 08, 2005 at 04:13:52PM -0600, Kumar Gala (galak@gate.crashing.org) wrote:
> On Wed, 23 Nov 2005, Jeff Garzik wrote:
> 
> > Alan Cox wrote:
> > >>Additionally, current IOAT is memory->memory.  I would love to be able 
> > >>to convince Intel to add transforms and checksums, 
> > > 
> > > 
> > > Not just transforms but also masks and maybe even merges and textures
> > > would be rather handy 8)
> > 
> > 
> > Ah yes:  I totally forgot to mention XOR.
> > 
> > Software RAID would love that.
> 
> A number of embedded processors already have HW that does these kinda of
> things.  On Freescale PPC processors there have been general purpose DMA
> engines for mem<->mem and more recently and additional crypto engines that
> allow for hashing, XOR, and security.
> 
> I'm actually searching for any examples of drivers that deal with the 
> issues related to DMA'ng directly two and from user space memory.
> 
> I have an ioctl based driver that does copies back and forth between user 
> and kernel space and would like to remove that since the crypto engine has 
> full scatter/gather capability.
> 
> The only significant effort I've come across is Peter Chubb's work for 
> user mode drivers which has some code for handling pinning of the user 
> space memory and what looks like generation of a scatter list.

Acrypto supports crypto processing directly in userspace pages.
In 2.6 it is quite easy using get_user_pages().

> - kumar
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
	Evgeniy Polyakov
