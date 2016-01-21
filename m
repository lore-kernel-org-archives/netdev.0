From: David Miller <davem@davemloft.net>
Subject: Re: Optimizing instruction-cache, more packets at each stage
Date: Thu, 21 Jan 2016 14:59:54 -0800 (PST)
Message-ID: <20160121.145954.398774513564415977.davem@davemloft.net>
References: <CAJ3xEMgPi-P6R39LOkBM67SehQE0MLxDXRB7qxCV5Y4WLORpXA@mail.gmail.com>
	<20160121.105608.180935122763399438.davem@davemloft.net>
	<CAJ3xEMjMg9fZGk-=F_nvx2Ta5z8fj9nrEEAm+xWYSm-hyUDDYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, tom@herbertland.com, eric.dumazet@gmail.com,
	edumazet@google.com, netdev@vger.kernel.org,
	alexander.duyck@gmail.com, alexei.starovoitov@gmail.com,
	borkmann@iogearbox.net, marek@cloudflare.com,
	hannes@stressinduktion.org, fw@strlen.de, pabeni@redhat.com,
	john.r.fastabend@intel.com, amirva@gmail.com, matanb@mellanox.com
To: gerlitz.or@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56043 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752146AbcAUW75 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 17:59:57 -0500
In-Reply-To: <CAJ3xEMjMg9fZGk-=F_nvx2Ta5z8fj9nrEEAm+xWYSm-hyUDDYg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <gerlitz.or@gmail.com>
Date: Fri, 22 Jan 2016 00:45:13 +0200

> Dave, at least in the ConnectX4 (mlx5e driver), as I commented earlier
> on this thread, we can use programmed tags reported by the HW on the
> completion of packets  whether the ethtype is ipv4 or ipv6 or
> something else, and let the kernel
> branch look into the packet memory on in the last case.

Fair enough.
