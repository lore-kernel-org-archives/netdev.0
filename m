From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] net: replace macros net_random and net_srandom with direct calls to prandom
Date: Sat, 11 Jan 2014 13:21:38 +0100
Message-ID: <20140111122138.GC30388@order.stressinduktion.org>
References: <1389442559-13097-1-git-send-email-aruna.hewapathirane@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Aruna-Hewapathirane <aruna.hewapathirane@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:56253 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752370AbaAKMVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jan 2014 07:21:39 -0500
Content-Disposition: inline
In-Reply-To: <1389442559-13097-1-git-send-email-aruna.hewapathirane@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 11, 2014 at 07:15:59AM -0500, Aruna-Hewapathirane wrote:
> This patch removes the net_random and net_srandom macros and replaces
> them with direct calls to the prandom ones. As new commits only seem to
> use prandom_u32 there is no use to keep them around.
> This change makes it easier to grep for users of prandom_u32.
> 
> Signed-off-by: Aruna-Hewapathirane <aruna.hewapathirane@gmail.com>
> Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks!
