From: Greg KH <greg@kroah.com>
Subject: Re: [stable] Re: [PATCH 2.6.17-rc1] Fix RtNetlink ENCODE security permissions
Date: Fri, 14 Apr 2006 11:06:52 -0700
Message-ID: <20060414180652.GA3797@kroah.com>
References: <20060414174726.GA24421@bougret.hpl.hp.com> <20060414105913.0222a8a6.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jt@hpl.hp.com, netdev@vger.kernel.org, linville@tuxdriver.com,
	stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:48848 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S1751373AbWDNSIB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2006 14:08:01 -0400
To: "Randy.Dunlap" <rdunlap@xenotime.net>
Content-Disposition: inline
In-Reply-To: <20060414105913.0222a8a6.rdunlap@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 14, 2006 at 10:59:13AM -0700, Randy.Dunlap wrote:
> On Fri, 14 Apr 2006 10:47:26 -0700 Jean Tourrilhes wrote:
> 
> > 	Hi John,
> > 
> > 	I've just realised that the RtNetlink code does not check the
> > permission for SIOCGIWENCODE and SIOCGIWENCODEEXT, which means that
> > any user can read the encryption keys. The fix is trivial and should
> > go in 2.6.17 alonside the two other patch I sent you last week.
> > 	Fully tested on 2.6.17-rc1.
> 
> and for -stable ??

At first glance, I'd agree with this.  Jean?

thanks,

greg k-h
