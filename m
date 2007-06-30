From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 2.2LK: Low link speed after suspend
Date: Sat, 30 Jun 2007 15:38:10 +0200
Message-ID: <20070630133810.GA15951@electric-eye.fr.zoreil.com>
References: <200704162241.31729.peter.missel@onlinehome.de> <200705012119.48598.peter.missel@onlinehome.de> <20070501200723.GA19212@electric-eye.fr.zoreil.com> <200706301448.50541.peter.missel@onlinehome.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Peter Missel <peter.missel@onlinehome.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:39751 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756979AbXF3NkO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jun 2007 09:40:14 -0400
Content-Disposition: inline
In-Reply-To: <200706301448.50541.peter.missel@onlinehome.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter Missel <peter.missel@onlinehome.de> :
[...]
> It is now on 2.6.21.5 as downloaded from www.kernel.org, built for AMD64.	
> Unfortunately, the problem is not gone. After suspend-to-disk and resume,
> link speed is 100. Unplugging and replugging the cable does not help.
> Unloading and reloading the driver module brings it back up to 1000.

Ok.

> But now I should have a driver that supports mii_tool, right ?

Yes.

> Since I cannot seem to find this tool available for download, could you
> please give me a pointer, or mail me the source? 

Oops, mii-tool is not included in the net-tool package by Suse.

You can follow http://freshmeat.net/projects/mii-tool.

/me digs in the pending bugs mailbox...

Apparently there is no currently known version of the kernel/driver
whose behavior would be different, right ?

Can you try if it is enough to bring the link back to 1000 to:
- ifconfig down/up the adapter
- kick it with mii-tool

Whatever the result, it would be nice to test the latest patchkit which
will go into mainline (i.e. any of:
http://www.fr.zoreil.com/people/francois/misc/20070628-2.6.22-rc6-r8169-test.patch
http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.22-rc6/r8169-20070628/
)

The patch will not apply directly against 2.6.21.5. Is it an option for
you to try 2.6.22-rc6 or are you stuck with 2.6.21.5 ?

-- 
Ueimor
