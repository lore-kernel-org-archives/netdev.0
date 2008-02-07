From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] ipvs: Make the synchronization interval controllable
Date: Wed, 6 Feb 2008 22:54:19 -0800 (PST)
Message-ID: <alpine.DEB.1.00.0802062253290.31533@chino.kir.corp.google.com>
References: <1202333990-19359-1-git-send-email-sven.wegener@stealer.net> <alpine.DEB.1.00.0802061409130.7879@chino.kir.corp.google.com> <Pine.LNX.4.64.0802062329150.15729@titan.stealer.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sven Wegener <sven.wegener@stealer.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:35013 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753889AbYBGGy3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2008 01:54:29 -0500
In-Reply-To: <Pine.LNX.4.64.0802062329150.15729@titan.stealer.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 7 Feb 2008, Sven Wegener wrote:

> Negative values will be converted to MAX_JIFFY_OFFSET by msecs_to_jiffies and
> result in a very long interval. A too long interval will be a good way to get
> your system OOM. We could use an unsigned int or even restrict the value with
> proc_dointvec_minmax. I'd prefer the latter, that's what I already had in my
> mind and it also protects from unintentionally choosing a too long interval.
> 

Yeah, you're definitely going to want an upper bound on acceptable values 
and not allow anything negative for the aforementioned reason.

		David
