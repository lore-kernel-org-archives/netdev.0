From: John Linn <John.Linn@xilinx.com>
Subject: RE: [PATCH] Linux Device Driver for Xilinx LL TEMAC 10/100/1000 EthernetNIC
Date: Tue, 19 Aug 2008 15:42:04 -0600
Message-ID: <20080819214207.084C115A8055@mail165-dub.bigfish.com>
References: <48AA938C.4060309@dlasys.net> <20080819201445.F39181468062@mail206-wa4.bigfish.com> <48AB2E58.2050307@dlasys.net> <20080819205148.82EAC50060@mail88-dub.bigfish.com> <48AB38AF.6010007@dlasys.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <linuxppc-embedded@ozlabs.org>, <netdev@vger.kernel.org>,
	"Ben Hutchings" <bhutchings@solarflare.com>,
	"Stephen Neuendorffer" <stephenn@xilinx.com>
To: "David H. Lynch Jr." <dhlii@dlasys.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-dub.frontbridge.com ([213.199.154.16]:35120 "EHLO
	IE1EHSOBE004.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753266AbYHSVmL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 17:42:11 -0400
Content-Class: urn:content-classes:message
In-Reply-To: <48AB38AF.6010007@dlasys.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I screwed up and forgot to copy all on this previously.

> -----Original Message-----
> From: David H. Lynch Jr. [mailto:dhlii@dlasys.net]
> Sent: Tuesday, August 19, 2008 3:19 PM
> To: John Linn
> Subject: Re: [PATCH] Linux Device Driver for Xilinx LL TEMAC
10/100/1000 EthernetNIC
> 
> John Linn wrote:
> >>     Stephen wants OF support -which is fine,  but I can not test
that.
> >>
> >
> > I definitely agree with Stephen that OF support is needed since
arch/ppc
> > has gone away. We aren't doing any new work on arch/ppc.
> >
> > Are you not planning to move to arch/powerpc anytime soon?  I could
help
> > you with that transition which would be better in the long run.  I'd
> > rather do that than do testing for you as I think it would be more
> > productive, but I've been wrong before.
> >
> 
> We will move to powerpc, but not in the time-frame I am hoping for
this
> driver.
> In the context of Linux and Pico, "we" means me, and there is no time
to
> do the work anytime soon.
> 

<snip>

What about you getting all the review & testing done and then we
(Xilinx) will add the OF support to the driver? 

I doubt the powerpc mainline will take the driver without OF support. In
fact, we had to remove the platform bus support from the last driver
that we put into mainline for arch/powerpc.

> 
> >> I would like
> >>     one and only one tag that can be used end-end.
> >>
> >>     Is there something xilinx will object to ? Prefer ? ....
> >>
> >>
> > xilinx_<device name>, (xilinx_lltemac or xilinx_ps2) is what we use
for
> > file names. The device tree does use "xlnx" to identify xilinx
devices,
> > but I don't think that should dictate file names.
> >
> > We have a driver in out GIT tree that is not flat (as most know) for
the
> > LL TEMAC and we are working on creating flat drivers for future
devices.
> > Ideally this new driver would be a replacement for our driver.
> >
> 
> Give me a name and I will go with it. the xps_lltemac name came from
> Yoshio,
> It is not in stone.
> 
> If I name the module "xilinx_lltemac" and go with xilinx_lltemac.c for
> the file name,
> is that going to cause problems with xilinx ?
> 
> I will use whatever you recomend.

xilinx_lltemac is the preferred. 

I don't think using xilinx_lltemac should cause problems.  Our Xilinx
Git tree has a xilinx_lltemac subdir that contains the non-flat driver
but that should be ok with your xilinx_lltemac.c file in the net
directory.

> 
> --
> Dave Lynch 					  	    DLA Systems
> Software Development:
Embedded Linux
> 717.627.3770 	       dhlii@dlasys.net 	  http://www.dlasys.net
> fax: 1.253.369.9244 			           Cell: 1.717.587.7774
> Over 25 years' experience in platforms, languages, and technologies
too numerous to list.
> 
> "Any intelligent fool can make things bigger and more complex... It
takes a touch of genius - and a
> lot of courage to move in the opposite direction."
> Albert Einstein
> 


This email and any attachments are intended for the sole use of the named recipient(s) and contain(s) confidential information that may be proprietary, privileged or copyrighted under applicable law. If you are not the intended recipient, do not read, copy, or forward this email message or any attachments. Delete this email message and any attachments immediately.


