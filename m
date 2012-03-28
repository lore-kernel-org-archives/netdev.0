From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 0/6] net/mlx4_en: DCB QoS support
Date: Wed, 28 Mar 2012 19:23:13 -0400 (EDT)
Message-ID: <20120328.192313.1006023795337428474.davem@davemloft.net>
References: <1332860951-23042-1-git-send-email-amirv@mellanox.com>
	<CAJZOPZLLJdQX4i_WhV8Bo5UHaxndFDwf873n8ZTCPqXq7JrMiw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roland@purestorage.com,
	yevgenyp@mellanox.com, oren@mellanox.com, amirv@dev.mellanox.co.il,
	john.r.fastabend@intel.com, eric.dumazet@gmail.com,
	amirv@mellanox.com
To: or.gerlitz@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59908 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758081Ab2C1XX2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2012 19:23:28 -0400
In-Reply-To: <CAJZOPZLLJdQX4i_WhV8Bo5UHaxndFDwf873n8ZTCPqXq7JrMiw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <or.gerlitz@gmail.com>
Date: Thu, 29 Mar 2012 00:21:57 +0200

> For the ratelimit Eric D. provided feedback and it was implemented
> along his suggestion,
> and now John and Ben have other suggestions, so need clear feedback
> here not to implement this in 2-3 different ways, and this is the
> easier piece. As for the HW QoS, the discussion continues.

I think the ratelimit stuff needs to be an optional attribute to
the existing dcbnl stuff, and I think that's in line with the
most recent suggestions you've received.

Definitely not module parameters or sysctl knobs, anything but that.
