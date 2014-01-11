From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] net: replace macros net_random and net_srandom with direct calls to prandom
Date: Sat, 11 Jan 2014 19:58:27 +0100
Message-ID: <20140111185827.GC6586@order.stressinduktion.org>
References: <1389442559-13097-1-git-send-email-aruna.hewapathirane@gmail.com> <1389462757.2537.61.camel@joe-AO722> <20140111180025.GB6586@order.stressinduktion.org> <1389465789.2537.66.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Aruna-Hewapathirane <aruna.hewapathirane@gmail.com>,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:56890 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751274AbaAKS63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jan 2014 13:58:29 -0500
Content-Disposition: inline
In-Reply-To: <1389465789.2537.66.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Sat, Jan 11, 2014 at 10:43:09AM -0800, Joe Perches wrote:
> There are a few places where reciprocal_device is
> used today without using reciprocal_value()

Maybe it would be helpful to clean those up and maybe introduce a
typedef struct { u32 i; } reciprocal_t; to make it harder to misuse this api.
;)

Greetings,

  Hannes
