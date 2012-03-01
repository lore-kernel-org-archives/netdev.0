From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/10] af_unix: add multicast and filtering features to
 AF_UNIX
Date: Thu, 01 Mar 2012 17:08:48 -0500 (EST)
Message-ID: <20120301.170848.432407217191581288.davem@davemloft.net>
References: <1330604802.2465.43.camel@edumazet-laptop>
	<20120301.154415.1692328508436381200.davem@davemloft.net>
	<CABBYNZJ-xxQXAx+ecrkVLqmWFaUVqLcQLj0Jxa3McSLnkLJSJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, javier.martinez@collabora.co.uk,
	rodrigo.moya@collabora.co.uk, javier@collabora.co.uk,
	lennart@poettering.net, kay.sievers@vrfy.org,
	alban.crequy@collabora.co.uk, bart.cerneels@collabora.co.uk,
	sjoerd.simons@collabora.co.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: luiz.dentz@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CABBYNZJ-xxQXAx+ecrkVLqmWFaUVqLcQLj0Jxa3McSLnkLJSJw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Luiz Augusto von Dentz <luiz.dentz@gmail.com>
Date: Fri, 2 Mar 2012 00:01:40 +0200

> I don't think you understood the problem, we want something that scale
> for less powerful devices, why do you think Android have all the
> trouble to create binder?

So our protocol stack is so cpu hungry compared to AF_UNIX that it's
unusable on low power devices?

I can't take you seriously if you say this after showing us the
thousands of lines of code you guys think we should add to the AF_UNIX
socket layer.

> Besides what is really the point in having AF_UNIX if you can't use
> for what it is for?

Because it doesn't have the handful of extra features you absolutely
require of it.

AF_UNIX is a complicated socket layer which is already extremely hard
to maintain.  We're still finding bugs in it even after all these
years, and that's without adding major new functionality.
