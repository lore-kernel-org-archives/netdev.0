From: Bob Copeland <me@bobcopeland.com>
Subject: Re: ath5k irq warning message
Date: Thu, 23 Apr 2009 08:06:38 -0400
Message-ID: <20090423120638.GA3168@hash.localnet>
References: <49EF9276.1060109@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.deathmatch.net ([72.66.92.28]:1274 "EHLO
	mail.deathmatch.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752506AbZDWMG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 08:06:59 -0400
Content-Disposition: inline
In-Reply-To: <49EF9276.1060109@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 22, 2009 at 02:56:06PM -0700, Ben Greear wrote:
> I notice this code in the ath5k_intr method.
>
> Won't counter be -1 if you break out of this due to the 'counter-- > 0'
> clause?
>
> 	} while (ath5k_hw_is_intr_pending(ah) && counter-- > 0);

Good catch, I guess it should be --counter...

-- 
Bob Copeland %% www.bobcopeland.com

