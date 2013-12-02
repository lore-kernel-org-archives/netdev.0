From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [[PATCH stable <3.12]] xen-netback: fix refcnt unbalance for
 3.11 and earlier versions
Date: Mon, 2 Dec 2013 09:58:16 -0800
Message-ID: <20131202175816.GA26951@kroah.com>
References: <1385642889-11513-1-git-send-email-wei.liu2@citrix.com>
 <20131201044835.GB19516@kroah.com>
 <20131202120134.GA14293@zion.uk.xensource.com>
 <20131202171958.GA661@kroah.com>
 <20131202174954.GD14293@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	stable@vger.kernel.org, tomasz.wroblewski@citrix.com,
	Ian Campbell <ian.campbell@citrix.com>,
	Konrad Wilk <konrad.wilk@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:37825 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752914Ab3LBR6R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 12:58:17 -0500
Content-Disposition: inline
In-Reply-To: <20131202174954.GD14293@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 02, 2013 at 05:49:54PM +0000, Wei Liu wrote:
> On Mon, Dec 02, 2013 at 09:19:58AM -0800, Greg KH wrote:
> [...]
> > As 3.11.y is now dead, there's not much I can do with that one, but I
> > could use a backport for 3.10.y, as this patch does not apply there,
> > thanks.
> > 
> 
> Here it is.

Thanks, that worked.

greg k-h
