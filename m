From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: ARP table question
Date: Thu, 20 Nov 2008 12:33:22 -0500
Message-ID: <20081120173322.GM22491@kvack.org>
References: <49221929.7060504@candelatech.com> <49221CE1.9000807@hp.com> <49221F7A.8030706@candelatech.com> <20081120.003306.213001819.davem@davemloft.net> <49259D29.3070308@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	netdev@vger.kernel.org, kaber@trash.net
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oldkanga.kvack.org ([66.96.29.28]:34515 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750969AbYKTRqt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2008 12:46:49 -0500
Content-Disposition: inline
In-Reply-To: <49259D29.3070308@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 20, 2008 at 09:23:53AM -0800, Ben Greear wrote:
> You think something like an exponential backoff capped at some 
> user-configurable
> max-value would be better?

I'll throw in an observation on arp behaviour on wifi / HomePNA: neither 
protocol provides reliable delivery of broadcast traffic, while point to 
point traffic is reliably delivered.  If arp traffic is not sufficiently 
aggressive when a connection is first used, the user can end up waiting 
some time until one of the broadcast packets finally gets through.  Doing 
an exponential backoff will make this significantly worse, unless the 
initial timeout is sufficiently small.

		-ben
-- 
"Time is of no importance, Mr. President, only life is important."
Don't Email: <zyntrop@kvack.org>.
