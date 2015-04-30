From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH -next] net: sched: remove TC_MUNGED bits
Date: Thu, 30 Apr 2015 14:16:24 -0700
Message-ID: <20150430211620.GA13076@Alexeis-MBP.westell.com>
References: <1430388720-5112-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:36909 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750766AbbD3VQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 17:16:29 -0400
Received: by igblo3 with SMTP id lo3so24801545igb.0
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 14:16:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1430388720-5112-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 30, 2015 at 12:12:00PM +0200, Florian Westphal wrote:
> Not used.
> 
> pedit sets TC_MUNGED when packet content was altered, but all the core
> does is unset MUNGED again and then set OK2MUNGE.
> 
> And the latter isn't tested anywhere. So lets remove both
> TC_MUNGED and TC_OK2MUNGE.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Wanted to do the same.
iproute2 doesn't use 'munge' flag either.

Acked-by: Alexei Starovoitov <ast@plumgrid.com>
