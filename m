From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/10] af_unix: add multicast and filtering features to
 AF_UNIX
Date: Fri, 02 Mar 2012 03:55:09 -0500 (EST)
Message-ID: <20120302.035509.1994457175982020283.davem@davemloft.net>
References: <CABBYNZJ-xxQXAx+ecrkVLqmWFaUVqLcQLj0Jxa3McSLnkLJSJw@mail.gmail.com>
	<20120301.170848.432407217191581288.davem@davemloft.net>
	<CABBYNZLwHKd5srzYYzWNL-iaeuH1K31824pY_bjRSbSLkv0QtA@mail.gmail.com>
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
In-Reply-To: <CABBYNZLwHKd5srzYYzWNL-iaeuH1K31824pY_bjRSbSLkv0QtA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Luiz Augusto von Dentz <luiz.dentz@gmail.com>
Date: Fri, 2 Mar 2012 10:39:24 +0200

> Like I said before there is many projects using AF_UNIX as IPC
> transport, the documentation actually induces people to use for this
> purpose, and many would benefit from being able to do multicast.

You can't have it both ways.

If it's useful for many applications, then many applications would
benefit from a userland library that solved the problem using
existing facilities such as IP multicast.

If it's only useful for dbus that that absoltely means we should
not add thousands of lines of code to the kernel specifically for
that application.

So either way, kernel changes are not justified.
