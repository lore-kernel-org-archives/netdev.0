From: Benjamin LaHaise <bcrl@lhnet.ca>
Subject: Re: regression: unregister_netdev() unusably slow
Date: Sun, 24 May 2009 17:44:33 -0400
Message-ID: <20090524214433.GH24757@kvack.org>
References: <20090524192150.GE24757@kvack.org> <200905250023.31056.denys@visp.net.lb> <20090524213744.GG24757@kvack.org> <4A19BF39.4000305@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryschenko <denys@visp.net.lb>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:48933 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752991AbZEXVpN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 May 2009 17:45:13 -0400
Content-Disposition: inline
In-Reply-To: <4A19BF39.4000305@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 24, 2009 at 11:42:17PM +0200, Eric Dumazet wrote:
> (But vlan case might be litle bit more expensive than your case, since we call
> synchronize_net() three times (once in unregister_vlan_dev(), and twice in rollback_registered()

I did try commenting out the synchronize_net() calls in rollback_registered(), 
but that had almost no effect on the rate of interface deletion.  50ms is 
still way too expensive.

		-ben
