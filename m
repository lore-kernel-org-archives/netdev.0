From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [GIT PULL] Remove __dev* markings from the networking drivers
Date: Tue, 4 Dec 2012 12:30:52 -0800
Message-ID: <20121204203052.GB32674@kroah.com>
References: <20121203202743.GA29451@kroah.com>
 <20121203.153623.958379034481583512.davem@davemloft.net>
 <20121204.131726.103739824056368439.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, wfp5p@virginia.edu
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:53465 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752005Ab2LDUa4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2012 15:30:56 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so3095806pbc.19
        for <netdev@vger.kernel.org>; Tue, 04 Dec 2012 12:30:55 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20121204.131726.103739824056368439.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 04, 2012 at 01:17:26PM -0500, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Mon, 03 Dec 2012 15:36:23 -0500 (EST)
> 
> > From: Greg KH <gregkh@linuxfoundation.org>
> > Date: Mon, 3 Dec 2012 12:27:43 -0800
> > 
> >> Here's a pull request for all of Bill's __dev* removal patches for the
> >> networking drivers, based on net-next.  I'll send out a separate one for
> >> the wireless drivers in case those want to go through John's tree
> >> 
> >> If I should rework these in any way, please let me know.
> > 
> > Pulled, thanks Greg.
> 
> I had a reason to go look in detail at the changes in here.
> 
> It seemse the function declarations were not properly reformatted
> after the __dev* tags were removed.  You can't just search and replace
> this kind of stuff.  The result looks terrible.
> 
> Greg please check for things like this next time you send me changes
> written by someone else.

Ick, sorry about that.  Want me to fix them all back up?  It's the least
I could do.

greg k-h
