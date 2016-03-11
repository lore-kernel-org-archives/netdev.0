From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH 3/3] bridge: allow zero ageing time
Date: Fri, 11 Mar 2016 11:31:30 +0100
Message-ID: <20160311103130.GC3931@nanopsycho.orion>
References: <1457470775-32224-1-git-send-email-stephen@networkplumber.org>
 <1457470775-32224-4-git-send-email-stephen@networkplumber.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Stephen Hemminger <shemming@brocade.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35436 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751359AbcCKKbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 05:31:33 -0500
Received: by mail-wm0-f67.google.com with SMTP id n205so1586793wmf.2
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2016 02:31:32 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1457470775-32224-4-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Mar 08, 2016 at 09:59:35PM CET, stephen@networkplumber.org wrote:
>From: Stephen Hemminger <shemming@brocade.com>
>
>This fixes a regression in the bridge ageing time caused by:
>commit c62987bbd8a1 ("bridge: push bridge setting ageing_time down to switchdev")
>
>There are users of Linux bridge which use the feature that if ageing time
>is set to 0 it causes entries to never expire. See:
>  https://www.linuxfoundation.org/collaborate/workgroups/networking/bridge
>
>For a pure software bridge, it is unnecessary for the code to have
>arbitrary restrictions on what values are allowable.
>
>Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Acked-by: Jiri Pirko <jiri@mellanox.com>
