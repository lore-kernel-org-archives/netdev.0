From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net] rhashtable: ensure cache line alignment on
 bucket_table
Date: Fri, 20 Feb 2015 23:39:03 +0000
Message-ID: <20150220233903.GA13890@casper.infradead.org>
References: <1424443737.5565.12.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:55106 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754600AbbBTXjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 18:39:07 -0500
Content-Disposition: inline
In-Reply-To: <1424443737.5565.12.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/20/15 at 06:48am, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> struct bucket_table contains mostly read fields :
> 
> size, locks_mask, locks.
> 
> Make sure these are not sharing a cache line with buckets[]
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
