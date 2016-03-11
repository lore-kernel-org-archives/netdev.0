From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH 1/3] mlxsw: spectrum: Check requested ageing time is valid
Date: Fri, 11 Mar 2016 11:31:01 +0100
Message-ID: <20160311103101.GA3931@nanopsycho.orion>
References: <1457470775-32224-1-git-send-email-stephen@networkplumber.org>
 <1457470775-32224-2-git-send-email-stephen@networkplumber.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Ido Schimmel <idosch@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34293 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751366AbcCKKbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 05:31:04 -0500
Received: by mail-wm0-f65.google.com with SMTP id p65so1596824wmp.1
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2016 02:31:03 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1457470775-32224-2-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Mar 08, 2016 at 09:59:33PM CET, stephen@networkplumber.org wrote:
>From: Ido Schimmel <idosch@mellanox.com>
>
>Commit c62987bbd8a1 ("bridge: push bridge setting ageing_time down to
>switchdev") added a check for minimum and maximum ageing time, but this
>breaks existing behaviour where one can set ageing time to 0 for a
>non-learning bridge.
>
>Push this check down to the driver and allow the check in the bridge
>layer to be removed. Currently ageing time 0 is refused by the driver,
>but we can later add support for this functionality.
>
>Signed-off-by: Ido Schimmel <idosch@mellanox.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
