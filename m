From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: why usr/include/linux/if_frad.h is required
Date: Thu, 22 Jan 2009 06:37:36 +0100
Message-ID: <20090122053736.GA6214@uranus.ravnborg.org>
References: <20090121053310.GA26395@uranus.ravnborg.org> <20090120.221504.264090722.davem@davemloft.net> <20090121173838.3390e5c9@s6510> <20090121.153712.84781438.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, jaswinderlinux@gmail.com, khc@pm.waw.pl,
	jaswinder@kernel.org, arnd@arndb.de, mingo@elte.hu,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfepb.post.tele.dk ([195.41.46.236]:48108 "EHLO
	pfepb.post.tele.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752059AbZAVFfx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 00:35:53 -0500
Content-Disposition: inline
In-Reply-To: <20090121.153712.84781438.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 21, 2009 at 03:37:12PM -0800, David Miller wrote:
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Wed, 21 Jan 2009 17:38:38 +1100
> 
> > There are no references if_frad.h in the version of Sangoma (out of
> > tree) code that we use in Vyatta.
> 
> frad-0.20:src/dlcicfg.c
> 
> It includes linux/if_frad.h and also performs the DLCI_SET_CONF
> ioctl.
> 
> Enough evidence to show we need to keep this header in the
> export set.  Let's just kill the bogus CONFIG_* ifdef
> tests in there.

Thanks for investigating David.

	Sam

