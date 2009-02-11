From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [git-pull -tip V2] fix compilation warnings
Date: Wed, 11 Feb 2009 21:05:55 +0100
Message-ID: <20090211200555.GA1636@elte.hu>
References: <1234377797.3910.6.camel@localhost.localdomain> <1234379780.3910.8.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: x86 maintainers <x86@kernel.org>,
	David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	airlied@linux.ie, netdev@vger.kernel.org,
	Jeremy Fitzhardinge <jeremy@goop.org>
To: Jaswinder Singh Rajput <jaswinder@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:45078 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755085AbZBKUGP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Feb 2009 15:06:15 -0500
Content-Disposition: inline
In-Reply-To: <1234379780.3910.8.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Jaswinder Singh Rajput <jaswinder@kernel.org> wrote:

> The following changes since commit 5765fcf36081bafa06b9553376bd99ceb629beb8:
>   Ingo Molnar (1):
>         Merge branch 'linus'
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/jaswinder/linux-2.6-tipclean.git master
> 
> Jaswinder Singh Rajput (7):
>       x86: mm/init_32.c fix compilation warning
>       x86: kernel/mpparse.c fix compilation warnings
>       drm_proc.c fix compilation warning
>       falcon fix compilation warnings
>       iscsi_ibft.c fix compilation warning
>       ne3210.c fix compilation warning for phys_addr_t
>       arlan-main.c fix compilation warnings for phys_addr_t
> 
>  arch/x86/kernel/mpparse.c         |    6 +++---
>  arch/x86/mm/init_32.c             |    2 +-
>  drivers/firmware/iscsi_ibft.c     |    4 ++--
>  drivers/gpu/drm/drm_proc.c        |    4 ++--
>  drivers/net/ne3210.c              |    3 ++-
>  drivers/net/sfc/falcon.c          |   24 ++++++++++++------------
>  drivers/net/wireless/arlan-main.c |    4 ++--
>  7 files changed, 24 insertions(+), 23 deletions(-)

Pulled, thanks Jaswinder.

For those wondering about how these files can be affected by the x86 tree,
it's fallout of:

  976e8f6: x86: asm/io.h: unify virt_to_phys/phys_to_virt

Which standardized the return type of virt_to_phys() to phys_addr_t, and
caused these build warnings.

	Ingo
