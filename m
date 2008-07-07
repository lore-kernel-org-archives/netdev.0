From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [Oops] fib_trie with ip route add throw since 2.6.25
Date: Mon, 7 Jul 2008 21:25:59 +0100
Message-ID: <20080707202558.GF28029@solarflare.com>
References: <20080707184144.GA17506@yuri.org.uk> <20080707195744.GE28029@solarflare.com> <20080707131212.2b1e0a5c@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: William Boughton <bill@boughton.de>, netdev@vger.kernel.org,
	stephen.hemminger@vyatta.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.mbr-roch.zen.net.uk ([212.23.3.141]:50076 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755530AbYGGU0H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 16:26:07 -0400
Content-Disposition: inline
In-Reply-To: <20080707131212.2b1e0a5c@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
[...]
> Agreed, a little more explanation would be good
>    * return values?? fn_trie_lookup is same as fn_hash_lookup
>    * check_leaf use return value of fn_trie_lookup so it can warpout without conditional
>    * this needs some comments.

It does, doesn't it?  I still don't know what the return values mean, but
when William found this I stared at the diff and looked at the callers
until I spotted what the functional change was. :-)

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
