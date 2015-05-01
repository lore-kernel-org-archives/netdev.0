From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH -next] net: sched: remove TC_MUNGED bits
Date: Fri, 01 May 2015 14:55:58 +0200
Message-ID: <554377DE.6070106@iogearbox.net>
References: <1430388720-5112-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41166 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751635AbbEAM4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 08:56:00 -0400
In-Reply-To: <1430388720-5112-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/30/2015 12:12 PM, Florian Westphal wrote:
> Not used.
>
> pedit sets TC_MUNGED when packet content was altered, but all the core
> does is unset MUNGED again and then set OK2MUNGE.
>
> And the latter isn't tested anywhere. So lets remove both
> TC_MUNGED and TC_OK2MUNGE.
>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Also looks good, thanks Florian!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
