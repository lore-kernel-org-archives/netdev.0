From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Oops] fib_trie with ip route add throw since 2.6.25
Date: Mon, 07 Jul 2008 22:29:04 +0200
Message-ID: <48727C90.6060604@trash.net>
References: <20080707184144.GA17506@yuri.org.uk> <20080707195744.GE28029@solarflare.com> <20080707131212.2b1e0a5c@extreme> <20080707202558.GF28029@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	William Boughton <bill@boughton.de>, netdev@vger.kernel.org,
	stephen.hemminger@vyatta.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37648 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755660AbYGGU3J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 16:29:09 -0400
In-Reply-To: <20080707202558.GF28029@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> Stephen Hemminger wrote:
> [...]
>> Agreed, a little more explanation would be good
>>    * return values?? fn_trie_lookup is same as fn_hash_lookup
>>    * check_leaf use return value of fn_trie_lookup so it can warpout without conditional
>>    * this needs some comments.
> 
> It does, doesn't it?  I still don't know what the return values mean, but
> when William found this I stared at the diff and looked at the callers
> until I spotted what the functional change was. :-)

They are suppposed to mirror the fib_semantic_match return values
if I recall correctly.
