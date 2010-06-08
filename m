From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: fix random mdio_write failures
Date: Tue, 8 Jun 2010 08:26:26 +0200
Message-ID: <20100608062626.GA3197@electric-eye.fr.zoreil.com>
References: <4C0A1736.9030209@iki.fi>
 <1275733273-28321-1-git-send-email-timo.teras@iki.fi>
 <20100605124103.GA3213@electric-eye.fr.zoreil.com>
 <4C31B2E3BE2B481DB749C669DFE23645@realtek.com.tw>
 <20100607215115.GA6583@electric-eye.fr.zoreil.com>
 <4C0DDDCC.6010500@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hayeswang <hayeswang@realtek.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Timo =?utf-8?B?VGVyw6Rz?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 30.185.140-88.rev.gaoland.net ([88.140.185.30]:43103 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753169Ab0FHG0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 02:26:53 -0400
Content-Disposition: inline
In-Reply-To: <4C0DDDCC.6010500@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Ter=C3=A4s <timo.teras@iki.fi> :
[ok]
> iteration. It sounds unlikely that polling the status register would
> slow down the actual write operation (if that is the case then 100us
> would be desirable).

I would not be that surprized.

> Changing my 25us to 20us would good. The original 25us was just a gue=
ss.
> The comment should be probably also updated that those delays are fro=
m
> realtek hw specs then.

Yes.

> Would you like me to send a patch?

Of course. Some comment from Hayes regarding mdio_read would be
welcome beforehand though.

--=20
Ueimor
