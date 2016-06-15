From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/sched: flower: Return error when hw can't
 offload and skip_sw is set
Date: Tue, 14 Jun 2016 22:30:06 -0700 (PDT)
Message-ID: <20160614.223006.189994765324675237.davem@davemloft.net>
References: <20160613090639.31110-1-amir@vadai.me>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com,
	john.r.fastabend@intel.com, jakub.kicinski@netronome.com,
	ogerlitz@mellanox.com, hadarh@mellanox.com, amirva@mellanox.com
To: amir@vadai.me
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54183 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745AbcFOFaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 01:30:08 -0400
In-Reply-To: <20160613090639.31110-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amir@vadai.me>
Date: Mon, 13 Jun 2016 12:06:39 +0300

> From: Amir Vadai <amirva@mellanox.com>
> 
> When skip_sw is set and hardware fails to apply filter, return error to
> user. This will make error propagation logic similar to the one
> currently used in u32 classifier.
> Also, changed code to use tc_skip_sw() utility function.
> 
> Signed-off-by: Amir Vadai <amirva@mellanox.com>

Applied, thanks.
