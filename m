From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/2] genetlink: trigger BUG_ON if a group name is too
 long
Date: Wed, 20 Mar 2013 17:32:59 +0000
Message-ID: <1363800779.2677.16.camel@bwh-desktop.uk.solarflarecom.com>
References: <1363693648-10015-1-git-send-email-yamato@redhat.com>
	 <1363693648-10015-2-git-send-email-yamato@redhat.com>
	 <20130320.120705.58997943737455552.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <yamato@redhat.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:30431 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751077Ab3CTRdC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 13:33:02 -0400
In-Reply-To: <20130320.120705.58997943737455552.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-03-20 at 12:07 -0400, David Miller wrote:
> From: Masatake YAMATO <yamato@redhat.com>
> Date: Tue, 19 Mar 2013 20:47:27 +0900
> 
> > Trigger BUG_ON if a group name is longer than GENL_NAMSIZ.
> > 
> > Signed-off-by: Masatake YAMATO <yamato@redhat.com>
> 
> Applied, thanks.
> 
> Although I'm disappointed that the compiler doesn't say anything about
> this in the assignment.
> 
> We're assigning "char[16] = STRING" and it doesn't say anything if the
> final NULL char doesn't fit into the array.

Unfortunately the C standard says this is allowed.  (Though the C++
standard says it's not!)  That doesn't mean the compiler can't warn
about it, of course.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
