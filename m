From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gigaset: correct range checking off by one error
Date: Tue, 16 Mar 2010 14:27:58 -0700 (PDT)
Message-ID: <20100316.142758.231155261.davem@davemloft.net>
References: <20100316172048.CBC5240116@xenon.ts.pxnet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, error27@gmail.com, hjlipp@web.de,
	isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@kernel.org
To: tilman@imap.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41910
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754364Ab0CPV1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 17:27:38 -0400
In-Reply-To: <20100316172048.CBC5240116@xenon.ts.pxnet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tilman Schmidt <tilman@imap.cc>
Date: Tue, 16 Mar 2010 18:04:01 +0100

> Correct a potential array overrun due to an off by one error in the
> range check on the CAPI CONNECT_REQ CIPValue parameter.
> Found and reported by Dan Carpenter using smatch.
> 
> Impact: bugfix
> Signed-off-by: Tilman Schmidt <tilman@imap.cc>

Applied.
