From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 0/5] sky2: Resolve sky2_down/transmit races, lockless
 transmit
Date: Mon, 3 Aug 2009 08:52:30 -0700
Message-ID: <20090803085230.1fafee1a@nehalam>
References: <392fb48f0908030407v6fa32f23pb10ca91ecfb2fd67@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41434 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755219AbZHCPwq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2009 11:52:46 -0400
In-Reply-To: <392fb48f0908030407v6fa32f23pb10ca91ecfb2fd67@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 3 Aug 2009 20:07:49 +0900
Mike McCormack <mikem@ring3k.org> wrote:

> Hi Stephen,
> 
> Here is an alternate (and more intrusive) patch set to solve the
> transmit during restart issues.
> 
> These patches avoid introducing a new state variable by
> 
> * reworking the transmit queue to work without locks
> * tweaking sky2_down() to avoid invalid tx queue positions being
> received in the status queue
> 
> Please let me know if this looks better,

Looks good, I will checkout on a couple of (older) boards as well.

