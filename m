From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] don't allow / in class device names
Date: Fri, 13 Feb 2004 12:59:36 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040213205936.GE14048@kroah.com>
References: <20040213102755.27cf4fcd.shemminger@osdl.org> <20040213203448.GB14048@kroah.com> <20040213124555.00cbf3d7@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tommi Virtanen <tv@tv.debian.net>, Leann Ogasawara <ogasawara@osdl.org>,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040213124555.00cbf3d7@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Feb 13, 2004 at 12:45:55PM -0800, Stephen Hemminger wrote:
> > No, the "fix" is to just not do this in the driver.  I'm not going to
> > apply this patch, sorry.
> > 
> > thanks,
> > 
> > greg k-h
> 
> Bah, kernel API's should check there arguments.  One of my peeve's about sysfs is
> that it is far too lazy about checking it's inputs.  Especially, when the restrictions
> are not well documented, the code needs to validate.

But isn't a '/' character a valid character for a file or directory
name?  :) 

Yeah, it's pathalogical, but why burden the core from something that is
instantly obvious to the developer as a "wrong" thing to do?

It's much easier to see, "Oh, my driver created a stupid directory name
because of the string I told it to use", than "why in the world is the
driver core rejecting my register call when I _know_ it's a correct
structure".

thanks,

greg k-h
