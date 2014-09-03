From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] netlink: Safer deletion of sk_bind_node
Date: Tue, 02 Sep 2014 22:28:19 -0700 (PDT)
Message-ID: <20140902.222819.1246875721008896036.davem@davemloft.net>
References: <54058376.9090700@mentor.com>
	<20140902.115215.1488500321662046816.davem@davemloft.net>
	<5406A4FF.1090209@mentor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, tgraf@suug.ch, ebiederm@xmission.com,
	darkjames-ws@darkjames.pl, rgb@redhat.com, eric.dumazet@gmail.com,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: harish_kandiga@mentor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5406A4FF.1090209@mentor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Harish Jenny Kandiga Nagaraj <harish_kandiga@mentor.com>
Date: Wed, 3 Sep 2014 10:49:59 +0530

> If that is the case , then subscriptions of netlink_sock should have
> been updated after netlink_remove or netlink_release.  I don't see
> that happening.

Please do not top-post.  First provide the quoted context, then provide
your response afterwards, rather than the other way around.

The point I was trying to make is that all code paths that operate
on this list have to follow this rule, if there is a code path that
is not then that is your bug and that is where the fix belongs.

We're unexpectedly having double deletes occur on this list, I would
prefer if we don't paper over it by allowing it to silently succeed.
