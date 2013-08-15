From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net] tun: compare with 0 instead of total_len
Date: Thu, 15 Aug 2013 22:14:31 +0200
Message-ID: <1376597671.11676.149.camel@deadeye.wl.decadent.org.uk>
References: <732ec15a7682b3ab87858de0b19a0848f0ad8944.1376399185.git.wpan@redhat.com>
	 <20130813.192943.865924891130626725.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wpan@redhat.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:55205 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758889Ab3HOUOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 16:14:38 -0400
In-Reply-To: <20130813.192943.865924891130626725.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-08-13 at 19:29 -0700, David Miller wrote:
> From: Weiping Pan <wpan@redhat.com>
> Date: Tue, 13 Aug 2013 21:46:56 +0800
> 
> > Since we set "len = total_len" in the beginning of tun_get_user(),
> > so we should compare the new len with 0, instead of total_len,
> > or the if statement always returns false.
> > 
> > Signed-off-by: Weiping Pan <wpan@redhat.com>
> 
> Definitely looks correct to me, applied, thanks.

len is unsigned.  So while len > total_len is a poor way of checking for
underflow, len < 0 is much worse!

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
