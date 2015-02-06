From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] openvswitch: Initialize unmasked key and
 uid len
Date: Fri, 06 Feb 2015 11:44:07 -0800
Message-ID: <1423251847.31870.142.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1423250233-1529-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Joe Stringer <joestringer@nicira.com>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:39420 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755680AbbBFToJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 14:44:09 -0500
Received: by iecar1 with SMTP id ar1so3876869iec.6
        for <netdev@vger.kernel.org>; Fri, 06 Feb 2015 11:44:09 -0800 (PST)
In-Reply-To: <1423250233-1529-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-02-06 at 11:17 -0800, Pravin B Shelar wrote:
> Flow alloc needs to initialize unmasked key pointer. Otherwise
> it can crash kernel trying to free random unmasked-key pointer.

> Fixes: 74ed7ab9264("openvswitch: Add support for unique flow IDs.")
> CC: Joe Stringer <joestringer@nicira.com>
> Reported-by: Or Gerlitz <ogerlitz@mellanox.com>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---

Thanks Pravin

Acked-by: Eric Dumazet <edumazet@google.com>
