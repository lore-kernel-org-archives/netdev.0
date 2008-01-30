From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] [1/2] Skip empty hash buckets faster in /proc/net/tcp
Date: Wed, 30 Jan 2008 18:32:18 +0100
Message-ID: <20080130173217.GB9812@bingen.suse.de>
References: <20080130901.138686634@suse.de> <adasl0fb60b.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, meissner@suse.de, netdev@vger.kernel.org,
	davem@davemloft.net
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:52864 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755153AbYA3RcT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 12:32:19 -0500
Content-Disposition: inline
In-Reply-To: <adasl0fb60b.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 30, 2008 at 09:03:16AM -0800, Roland Dreier wrote:
>  > On a 2GB Core2 system here I see a time cat /proc/net/tcp > /dev/null
>  > constently dropping from 0.44s to 0.4-0.8s system time with this change.
> 
> Seems like there must be a typo in either the before or after times
> you report here?

Yes thanks, it was 0.44s down to 0.04s/0.08s here. Somehow the zeroes
got lost.

-Andi
