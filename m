From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/8] af_unix: find the recipients of a multicast group
Date: Fri, 21 Jan 2011 16:58:39 -0800 (PST)
Message-ID: <20110121.165839.221575506.davem@davemloft.net>
References: <20110121143751.57b1453d@chocolatine.cbg.collabora.co.uk>
	<1295620788-6002-5-git-send-email-alban.crequy@collabora.co.uk>
	<20110121172420.7ac74133@chocolatine.cbg.collabora.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, lennart@poettering.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ian.molton@collabora.co.uk
To: alban.crequy@collabora.co.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110121172420.7ac74133@chocolatine.cbg.collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alban Crequy <alban.crequy@collabora.co.uk>
Date: Fri, 21 Jan 2011 17:24:20 +0000

> I don't know if I should avoid releasing sockets in RCU callbacks or
> update the lockdep annotations.

Releasing sockets in RCU callbacks is dangerous at best.
