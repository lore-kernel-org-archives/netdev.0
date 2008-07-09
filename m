From: William Boughton <bill@boughton.de>
Subject: Re: [Oops] fib_trie with ip route add throw since 2.6.25
Date: Wed, 9 Jul 2008 06:55:41 +0200
Message-ID: <20080709045541.GA26981@yuri.org.uk>
References: <20080707184144.GA17506@yuri.org.uk> <20080707195744.GE28029@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stephen.hemminger@vyatta.com,
	Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from soapstone.yuri.org.uk ([78.47.151.105]:43847 "EHLO
	soapstone.yuri.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751026AbYGIEzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 00:55:50 -0400
Content-Disposition: inline
In-Reply-To: <20080707195744.GE28029@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 07, 2008 at 08:57:45PM +0100, Ben Hutchings wrote:

Hello,

> [...]
> 
> The changes to check_leaf() and fn_trie_lookup() seem to be wrong - where
> fn_trie_lookup() would previously return a negative error value from
> check_leaf(), it now returns 0.
> 
> Now fn_trie_lookup() doesn't appear to care about plen, so we could revert
> check_leaf() to returning the error value.  How does this work?
> 

I have been running with this patch on 2.6.26-rc9 on a  machine for 
24 hours on a machine that caused the oops before without any problems.


regards

Bill
-- 
Bill Boughton
