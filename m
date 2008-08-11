From: David Miller <davem@davemloft.net>
Subject: Re: tbench regression on each kernel release from 2.6.22 -> 2.6.28
Date: Mon, 11 Aug 2008 14:50:47 -0700 (PDT)
Message-ID: <20080811.145047.105665450.davem@davemloft.net>
References: <48A086B6.2000901@linux-foundation.org>
	<20080811.141501.01468546.davem@davemloft.net>
	<48A0B037.501@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: cl@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756539AbYHKVu7@vger.kernel.org>
In-Reply-To: <48A0B037.501@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Lameter <cl@linux-foundation.org>
Date: Mon, 11 Aug 2008 16:33:43 -0500

> Maybe what we are seeing is general bloat in kernel execution paths
> due to the growth in complexity?

It could be, and any kind of analysis into this would be great.

I had a change that RCU destroyed sockets and this added a
tiny bit of latency, so I never added it even though it would
have allowed a lot of simplification of socket handling (which
I though would make up for RCU's latency, but it didn't).
