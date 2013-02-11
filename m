From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v4 07/11] tbf: ignore max_size check for gso
 skbs
Date: Mon, 11 Feb 2013 16:11:07 -0500 (EST)
Message-ID: <20130211.161107.919817010099628482.davem@davemloft.net>
References: <1360493539-14868-1-git-send-email-jiri@resnulli.us>
	<1360493539-14868-8-git-send-email-jiri@resnulli.us>
	<20130211210220.GA1560@minipsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, jhs@mojatatu.com,
	kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42445 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759807Ab3BKVLL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 16:11:11 -0500
In-Reply-To: <20130211210220.GA1560@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 11 Feb 2013 22:02:20 +0100

> Hmm. I think that this approach might not be correct after all. This
> might break existing setups when user is taking gso into account and
> adjust mtu and burst accordingly. After more thorough study, I'm under
> impression that gso skbs should not be handled in any different way.
> 
> Thoughts?

I really think userspace should be ignorant of GSO to the maximum
extent to which that is possible.
