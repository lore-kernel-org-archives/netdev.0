From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: NET: ASSERT_RTNL in __dev_set_promiscuity makes debug warning
Date: Wed, 5 Dec 2007 07:25:41 +0100
Message-ID: <20071205062540.GA987@ff.dom.local>
References: <4755D42E.7050602@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joonwoo Park <joonwpark81@gmail.com>, netdev@vger.kernel.org,
	'Linux Kernel Mailing List' <linux-kernel@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:53314 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750892AbXLEGUv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2007 01:20:51 -0500
Content-Disposition: inline
In-Reply-To: <4755D42E.7050602@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04-12-2007 23:26, Jarek Poplawski wrote:
...
> But, IMHO, blowing ASSERT_RTNL up in a few places shouldn't be much
> worse. After all, how long such a debugging code should be kept. It
> seems, at least sometimes we should be a bit more confident of how
> it's called.

I see this won't be done this way, but, if it were, then there is no
reason to remove the second: documenting feature of ASSERT_RTNL, so
some comment about locking should be added.

Jarek P.
