From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH] net: switchdev: ignore unsupported bridge flags
Date: Tue, 23 Jun 2015 09:36:13 -0700
Message-ID: <CAE4R7bBCdcGWkFGAqB4o7Eq4W1wGVWeCXfG=Cy9HZJd6q_iX5g@mail.gmail.com>
References: <1435069564-10241-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:34162 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751055AbbFWQgd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 12:36:33 -0400
In-Reply-To: <1435069564-10241-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 23, 2015 at 7:26 AM, Vivien Didelot
<vivien.didelot@savoirfairelinux.com> wrote:
> switchdev_port_bridge_getlink() queries SWITCHDEV_ATTR_PORT_BRIDGE_FLAGS
> attributes, but a driver doesn't need to implement this in order to get
> bridge link information.
>
> So error out only on errors different than -EOPNOTSUPP.
>
> (This is a follow-up patch for 7d4f8d8.)
>
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Thanks for testing Vivien.

Acked-by: Scott Feldman <sfeldma@gmail.com>
