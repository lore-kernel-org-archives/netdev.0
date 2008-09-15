From: Adrian Bunk <bunk@kernel.org>
Subject: Re: linux-next: Tree for September 13 (3c509)
Date: Mon, 15 Sep 2008 17:11:49 +0300
Message-ID: <20080915141149.GA10002@cs181140183.pp.htv.fi>
References: <20080913162344.ab395285.sfr@canb.auug.org.au> <20080914141757.899f71eb.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Randy Dunlap <randy.dunlap@oracle.com>,
	Hannes Reinecke <hare@suse.de>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5.pp.htv.fi ([213.243.153.39]:48264 "EHLO smtp5.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752634AbYIOOMD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Sep 2008 10:12:03 -0400
Content-Disposition: inline
In-Reply-To: <20080914141757.899f71eb.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 14, 2008 at 02:17:57PM -0700, Randy Dunlap wrote:
> drivers/net/3c509.c fails (CONFIG_PM=y) with:
> 
> drivers/built-in.o:(.data+0x7dcc): undefined reference to `el3_resume'
> drivers/built-in.o:(.data+0x7e08): undefined reference to `el3_resume'
> 
> It seems that this function does not exist in the source file.


It got removed by:


commit 107aeb9753159da848f066b26557f0aaab900a90
Author: Hannes Reinecke <hare@suse.de>
Date:   Wed Sep 10 14:16:04 2008 +0200

    Driver core: Use dev_get_drvdata() accessors
    
    Deprecated direct access to the ->driver_data field and
    use accessors throughout.
    
    Signed-off-by: Hannes Reinecke <hare@suse.de>
    Cc: Kay Sievers <kay.sievers@vrfy.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>


cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

