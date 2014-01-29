From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: Re: [PATCH] iproute: Properly handle protocol level diag module absence
Date: Wed, 29 Jan 2014 11:39:51 -0800 (PST)
Message-ID: <1391024391.38232.YahooMailBasic@web125506.mail.ne1.yahoo.com>
References: <52E7E990.7050501@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm38.bullet.mail.ne1.yahoo.com ([98.138.229.31]:32087 "EHLO
	nm38.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751040AbaA2Tmu convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jan 2014 14:42:50 -0500
In-Reply-To: <52E7E990.7050501@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 1/28/14, Pavel Emelyanov <xemul@parallels.com> wrote:

> When *_diag module is missing in the kernel, the ss tool should go
> ad read legacry /proc/* files.

> This is the case when all *_diag stuff is missing, but in case the
> inet_diag.ko is loaded, but (tcp|udp)_diag.ko is not, the ss tool
> doesn't notice this and produces empty output. The reason for that
> is -- error from the inet_diag module (which means, that e.g. the
> udp_diag is missing) is reported in the NLMSG_DONE message body.

> That said, we need to check the NLMSG_DONE's message return code
> and act respectively.

> Reported-by: Fran=E7ois-Xavier Le Bail <fx.lebail@yahoo.com>
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

> ---

Tested-by: Fran=E7ois-Xavier Le Bail <fx.lebail@yahoo.com>
