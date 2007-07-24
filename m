From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: [PATCH 1/2][RFC] Update net core to use devres.
Date: Wed, 25 Jul 2007 00:30:07 +0100
Message-ID: <20070724233007.GW21668@ftp.linux.org.uk>
References: <11853167931415-git-send-email-bphilips@suse.de> <11853167964115-git-send-email-bphilips@suse.de> <20070724225134.GV21668@ftp.linux.org.uk> <20070724230922.GA27392@ftp.linux.org.uk> <20070724232621.GB11350@ifup.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Brandon Philips <bphilips@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:51187 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755837AbXGXXaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 19:30:08 -0400
Content-Disposition: inline
In-Reply-To: <20070724232621.GB11350@ifup.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 24, 2007 at 04:26:21PM -0700, Brandon Philips wrote:
> Could you point me to an example you have in mind?
> 
> I quickly searched through a handful of the PCI device drivers and
> couldn't find an example where the .remove function didn't do something
> to the tune of:
> 
> 	unregister_netdev(dev);
> 	... various un-allocs and cleanup ...
> 	free_netdev(dev)

Now find the definition of free_netdev() and read it through, please.
