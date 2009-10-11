From: Greg KH <greg@kroah.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Sun, 11 Oct 2009 11:47:31 -0700
Message-ID: <20091011184731.GA4560@kroah.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com> <20091009140000.GA18765@mock.linuxdev.us.dell.com> <20091009210909.GA9836@auslistsprd01.us.dell.com> <20091009194401.036da080@nehalam> <20091010044056.GA5350@mock.linuxdev.us.dell.com> <20091010052308.GA12458@kroah.com> <20091010124731.GA17218@mock.linuxdev.us.dell.com> <20091010162518.GA30354@kroah.com> <1255279218.25232.4.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Domsch <Matt_Domsch@dell.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	Narendra_K@dell.com, jordan_hargrave@dell.com
To: David Zeuthen <david@fubar.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:35535 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750945AbZJKSs5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Oct 2009 14:48:57 -0400
Content-Disposition: inline
In-Reply-To: <1255279218.25232.4.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 11, 2009 at 12:40:18PM -0400, David Zeuthen wrote:
> On Sat, 2009-10-10 at 09:25 -0700, Greg KH wrote:
> > Ok, but that way can be done in userspace, without the need for this
> > char device, right?
> 
> It might actually be nice to have a device file anyway since you can use
> existing udev infrastructure to adjust permissions (e.g. chown it to the
> netdev group) and add ACLs. This would allow running some software as an
> unprivileged user instead of uid 0.

But as the char nodes would not actually control access to anything, how
would this help?  Remember, these device nodes are "dummies" with
nothing behind them (open() fails).

thanks,

greg k-h
