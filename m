From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: [PATCH 1/2][RFC] Update net core to use devres.
Date: Tue, 24 Jul 2007 23:51:34 +0100
Message-ID: <20070724225134.GV21668@ftp.linux.org.uk>
References: <11853167931415-git-send-email-bphilips@suse.de> <11853167964115-git-send-email-bphilips@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: bphilips@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:47010 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752557AbXGXWvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 18:51:35 -0400
Content-Disposition: inline
In-Reply-To: <11853167964115-git-send-email-bphilips@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 24, 2007 at 03:39:52PM -0700, bphilips@suse.de wrote:
> * netdev_pci_remove_one() can replace simple pci device remove
>   functions
> 
> * devm_alloc_netdev() is like alloc_netdev but allocates memory using devres.
>   alloc_netdev() can be removed once all drivers use devres.
 
Ewwww...  What the hell for?  To make sure that we have struct device
for everything, whether we need it or not?  Have you actually read
through drivers/net?  I mean, _really_ read through it, looking for
ugly cases...

I've done just that several times and I'm sorry, but I would classify
that project as hopeless.  It's way, _way_ more diverse than SATA...
