From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [PATCH] e1000, e1000e valid-addr fixes
Date: Wed, 24 Oct 2007 03:15:35 +0200
Message-ID: <20071024011535.GZ30533@stusta.de>
References: <471E2AD0.1000500@intel.com> <471E5C21.8030908@garzik.org> <20071023212026.GF7793@redhat.com> <20071023.145339.55504234.davem@davemloft.net> <471E9801.2000006@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, davej@redhat.com,
	auke-jan.h.kok@intel.com, ajax@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:40274 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752454AbXJXBPI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 21:15:08 -0400
Content-Disposition: inline
In-Reply-To: <471E9801.2000006@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 23, 2007 at 08:55:29PM -0400, Jeff Garzik wrote:
> Actually, looking over the code I see obvious bugs in the logic:
>
> An invalid ethernet address should not cause device loading to fail, 
> because the user is given the opportunity to supply a MAC address via 
> userspace (ifconfig or whatever) before the interface goes up.
> 
> I just created the attached -bug fix- patch as illustration, though I have 
> not committed it, waiting for comment.
>...

Is there a good reason why we have such checks duplicated in the drivers 
(with every driver doing it differently...) instead of doing it in 
net/core/dev.c?

> 	Jeff

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

