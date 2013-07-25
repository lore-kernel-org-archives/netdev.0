From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: qlcnic binary sysfs file abuse
Date: Thu, 25 Jul 2013 13:08:45 -0700
Message-ID: <20130725200845.GA19591@kroah.com>
References: <20130707002949.GA15822@kroah.com>
 <0EA5B226BC5C7B45A71BF612AA8A019E355A3BD4@AVMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Dept-Eng Linux Driver <Linux-Driver@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Sony Chacko <sony.chacko@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:38517 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756782Ab3GYUIr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 16:08:47 -0400
Content-Disposition: inline
In-Reply-To: <0EA5B226BC5C7B45A71BF612AA8A019E355A3BD4@AVMB1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 25, 2013 at 07:37:46PM +0000, Sony Chacko wrote:
> > -----Original Message-----
> > From: Greg KH [mailto:gregkh@linuxfoundation.org]
> > Sent: Saturday, July 06, 2013 5:30 PM
> > To: Rajesh Borundia; Shahed Shaikh; Jitendra Kalsaria; Sony Chacko; Dept-Eng
> > Linux Driver
> > Cc: netdev; linux-kernel
> > Subject: qlcnic binary sysfs file abuse
> > 
> > I was doing a kernel-wide audit on all of the binary sysfs files, and noticed a
> > metric ton of them in the qlcnic driver.
> > 
> > So, any objection to me just deleting these entirely?  Or, if they really are
> > needed, can I just move them to debugfs, which is where I think they should
> > have been from the beginning?
> 
> Some applications are using these files, please move them to debugfs.

What applications care about the internal data structures of the kernel
driver?  What can those applications do with that information?  What
happens when you have a 64bit kernel on a 32bit userspace?  How about
endian issues on different processor types?  That sounds like a
nightmare to even consider getting correct...

Anyway, I'll move them to debugfs, thanks.

greg k-h
