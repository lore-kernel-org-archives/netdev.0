From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH 2/3] rocker: set FDB cleanup timer according to lowest
 ageing time
Date: Fri, 11 Mar 2016 11:31:15 +0100
Message-ID: <20160311103115.GB3931@nanopsycho.orion>
References: <1457470775-32224-1-git-send-email-stephen@networkplumber.org>
 <1457470775-32224-3-git-send-email-stephen@networkplumber.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Ido Schimmel <idosch@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35230 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751238AbcCKKbR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 05:31:17 -0500
Received: by mail-wm0-f68.google.com with SMTP id n205so1585645wmf.2
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2016 02:31:17 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1457470775-32224-3-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Mar 08, 2016 at 09:59:34PM CET, stephen@networkplumber.org wrote:
>From: Ido Schimmel <idosch@mellanox.com>
>
>In rocker, ageing time is a per-port attribute, so the next time the FDB
>cleanup timer fires should be set according to the lowest ageing time.
>
>This will later allow us to delete the BR_MIN_AGEING_TIME macro, which was
>added to guarantee minimum ageing time in the bridge layer, thereby breaking
>existing behavior.
>
>Signed-off-by: Ido Schimmel <idosch@mellanox.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
