From: Rene Herman <rene.herman@keyaccess.nl>
Subject: Re: size of git repository (was Re: [BUG] New Kernel Bugs)
Date: Sun, 18 Nov 2007 16:19:56 +0100
Message-ID: <4740581C.6030206@keyaccess.nl>
References: <20071113031553.3c7b5c16.akpm@linux-foundation.org>	 <20071113.033946.114918709.davem@davemloft.net>	 <20071113034916.2556edd7.akpm@linux-foundation.org>	 <20071113.035824.40509981.davem@davemloft.net>	 <20071113041259.79c9a8c5.akpm@linux-foundation.org>	 <20071113134029.GA30978@elte.hu> <4739AFE0.20705@rtr.ca>	 <20071113164650.GA28493@elte.hu> <4739E3D0.10201@rtr.ca>	 <20071118124404.GA4037@ucw.cz>  <474036EA.9040600@keyaccess.nl> <1195396507.3288.4.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pavel Machek <pavel@ucw.cz>, Mark Lord <liml@rtr.ca>,
	Ingo Molnar <mingo@elte.hu>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, protasnb@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alsa-devel@alsa-project.org, linux-ide@vger.kernel.org,
	linux-pcmcia@lists.infradead.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	bugme-daemon@bugzilla.kernel.org
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpq1.groni1.gr.home.nl ([213.51.130.200]:46287 "EHLO
	smtpq1.groni1.gr.home.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750716AbXKRPYw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Nov 2007 10:24:52 -0500
In-Reply-To: <1195396507.3288.4.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 18-11-07 15:35, James Bottomley wrote:

>> clean-cg? But failure to run "git repack -a -d" every once in a while?
> 
> Actually, the best command is
> 
> git gc
> 
> which does a repack (into a single pack file rather than an incremenal), 
> and then removes all the objects now in the pack.  If, like me, you work 
> on temporary branches which you keep rebasing, you can add a --prune to 
> gc which will erase all unreferenced objects as it packs (use this one 
> with care.  I usually never use it but run a git prune -n just to see 
> what would be removed, and then run git prune separately if it looks OK).

Thanks for the comment. That managed to indeed shave a few extra bytes off 
my already "repack -a -d" packed repo still.

Rene.

