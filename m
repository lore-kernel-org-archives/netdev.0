From: Matthew Wilcox <willy@debian.org>
Subject: Re: [PATCH] ethtool_ops rev 4
Date: Sun, 3 Aug 2003 15:56:56 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030803145656.GI22222@parcelfarce.linux.theplanet.co.uk>
References: <20030801150232.GV22222@parcelfarce.linux.theplanet.co.uk> <20030801154021.GA7696@gtf.org> <20030801154656.GW22222@parcelfarce.linux.theplanet.co.uk> <20030801162536.GA18574@gtf.org> <20030802222145.GE22222@parcelfarce.linux.theplanet.co.uk> <3F2C3C86.6000202@pobox.com> <20030803002744.GF22222@parcelfarce.linux.theplanet.co.uk> <3F2C7E12.8070904@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthew Wilcox <willy@debian.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <3F2C7E12.8070904@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Aug 02, 2003 at 11:14:26PM -0400, Jeff Garzik wrote:
> Matthew Wilcox wrote:
> >Nothing stops it being implemented as a macro in kcompat.  Having it as
> >an inline function gives it argument typechecking which always gives me
> >the warm fuzzies.
> 
> No, it _needs_ to be a macro for maximum flexibility.
> 
> Most importantly, kcompat code may use '#ifndef SET_ETHTOOL_OPS' as a 
> trigger, to signal that compat code is needed.  No need for drivers to 
> create tons of kernel-version-code ifdefs, just to test for when 
> ethtool_ops appeared in 2.6, for when it starts appearing in 2.4 vendor 
> backports, and (possibly) 2.4 itself.  Also, doing it at the cpp level 
> allows compat code to #undef it, if it _really_ knows what its doing, 
> and the situation calls for it.

OK.  At this point, I really feel like I'm getting in the way and
hindering more than I'm helping.  Can I pass the torch to you and let
you finish the job?

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
