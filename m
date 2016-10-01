From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 2/2] mlxsw: spectrum_router: avoid potential uninitialized data usage
Date: Sat, 1 Oct 2016 05:36:30 +0200
Message-ID: <201610010536.30927.arnd@arndb.de>
References: <20160930161734.70928-1-arnd@arndb.de> <20160930161734.70928-2-arnd@arndb.de> <20160930175700.GA641@splinter>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@mellanox.com>, Ido Schimmel <idosch@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Yotam Gigi <yotamg@mellanox.com>,
        Nogah Frankel <nogahf@mellanox.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Ido Schimmel <idosch@idosch.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.187]:62741 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751721AbcJADne (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 23:43:34 -0400
In-Reply-To: <20160930175700.GA641@splinter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 30 September 2016, Ido Schimmel wrote:
> BTW, which flags did you pass to generate this error? I can only
> reproduce this with EXTRA_CFLAGS="-Wmaybe-uninitialized -Werror", but
> for some reason EXTRA_CFLAGS="-Wall -Werror" is silent. Any idea why? I
> would like to add this to my git hooks and avoid these errors in the
> future :)

Linus disabled the warning for v4.8. I've just talked to him today about this
warning in particular, and hope that we can find a way to enable it by
default again in the future, as a lot of possible bugs get introduced,
but certain compiler versions also produce a lot of false positives.

	Arnd
