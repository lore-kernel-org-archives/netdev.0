From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: more documentation for tcp_tw_reuse and
 tcp_tw_recycle
Date: Wed, 07 May 2014 15:16:37 -0400 (EDT)
Message-ID: <20140507.151637.562958118271192092.davem@davemloft.net>
References: <1399196499-8449-1-git-send-email-vincent@bernat.im>
	<1399196499-8449-2-git-send-email-vincent@bernat.im>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, linux-doc@vger.kernel.org,
	netdev@vger.kernel.org
To: vincent@bernat.im
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1399196499-8449-2-git-send-email-vincent@bernat.im>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vincent Bernat <vincent@bernat.im>
Date: Sun,  4 May 2014 11:41:39 +0200

> The documentation is not very helpful about what those settings
> affect. We find numerous tuning guides advising to set both these
> settings to 1 to reduce the number of entries in the TIME-WAIT
> state. However, enabling tcp_tw_recycle will cause massive problems when
> working with NAT.
> 
> The documentation is completed a bit to explain quickly what kind of
> connections both those settings will affect and to encourage the use of
> tcp_tw_reuse instead of tcp_tw_recycle for outgoing connections.

First of all your change locks a proper signoff.

Second of all, both options can cause problems in the presence of NAT
because both optimizations assume unique IP addresses identify unique
physical hosts.
