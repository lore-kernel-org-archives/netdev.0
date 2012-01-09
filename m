From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next v2 2/2] net: introduce netif_addr_lock_nested()
 and call if when appropriate
Date: Tue, 10 Jan 2012 00:47:43 +0100
Message-ID: <20120109234743.GA4896@minipsycho>
References: <1326125915-2711-1-git-send-email-jpirko@redhat.com>
 <1326125915-2711-2-git-send-email-jpirko@redhat.com>
 <20120109163654.GC2114@minipsycho.brq.redhat.com>
 <1326136028.2725.0.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, eric.dumazet@gmail.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28296 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933525Ab2AIXrs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jan 2012 18:47:48 -0500
Content-Disposition: inline
In-Reply-To: <1326136028.2725.0.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jan 09, 2012 at 08:07:08PM CET, bhutchings@solarflare.com wrote:
>On Mon, 2012-01-09 at 17:36 +0100, Jiri Pirko wrote:
>> dev_uc_sync() and dev_mc_sync() are acquiring netif_addr_lock for
>> destination device of synchronization. Since netif_addr_lock is already
>> held at the time for source device, this triggers depmod deathlock
>> warning.
>[...]
>
>I think you mean '...lockdep deadlock warning'?

That's him :) I mixed that up a bit. Sorry :(

Jirka

>
>Ben.
>
>-- 
>Ben Hutchings, Staff Engineer, Solarflare
>Not speaking for my employer; that's the marketing department's job.
>They asked us to note that Solarflare product names are trademarked.
>
