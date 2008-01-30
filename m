From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: b44 compile failure
Date: Wed, 30 Jan 2008 11:21:57 -0500
Message-ID: <20080130162157.GC3317@tuxdriver.com>
References: <20080130105926.GC24152@stro.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: zambrano@broadcom.com, netdev@vger.kernel.org
To: maximilian attems <max@stro.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3469 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758272AbYA3QcX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 11:32:23 -0500
Content-Disposition: inline
In-Reply-To: <20080130105926.GC24152@stro.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 30, 2008 at 11:59:26AM +0100, maximilian attems wrote:
>  drivers/net/b44.c: In function 'b44_remove_one':
>  drivers/net/b44.c:2231: error: implicit declaration of function 'ssb_pcihost_set_power_state'
> 
>  compiles fine on 64 bit x86, but not on 32, see log:
>  http://stats.buildserver.net/fetch.php?&pkg=linux-2.6&ver=2.6.24-trunk1%7Esnapshot.10272&arch=i386&stamp=1201665377&file=log&as=raw

It seems to build fine on my i686 box.  What dtree are you using?
And what is your .config?  Is CONFIG_SSB enabled?

Thanks,

John
-- 
John W. Linville
linville@tuxdriver.com
