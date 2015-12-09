From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net 2/2] openvswitch: Respect conntrack zone even if invalid
Date: Wed, 9 Dec 2015 15:34:15 -0800
Message-ID: <CALnjE+ro2mntirb_EDm7Aak2XHM=DPOW6gNbZ2C4z3LDj6WWVA@mail.gmail.com>
References: <1449698860-20685-1-git-send-email-joe@ovn.org>
	<1449698860-20685-2-git-send-email-joe@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Joe Stringer <joe@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:34587 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752867AbbLIXeQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 18:34:16 -0500
Received: by mail-ig0-f181.google.com with SMTP id g19so4348763igv.1
        for <netdev@vger.kernel.org>; Wed, 09 Dec 2015 15:34:16 -0800 (PST)
In-Reply-To: <1449698860-20685-2-git-send-email-joe@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 9, 2015 at 2:07 PM, Joe Stringer <joe@ovn.org> wrote:
> If userspace executes ct(zone=1), and the connection tracker determines
> that the packet is invalid, then the ct_zone flow key field is populated
> with the default zone rather than the zone that was specified. Even
> though connection tracking failed, this field should be updated with the
> value that the action specified. Fix the issue.
>
> Fixes: 7f8a436eaa2c ("openvswitch: Add conntrack action")
> Signed-off-by: Joe Stringer <joe@ovn.org>

Acked-by: Pravin B Shelar <pshelar@nicira.com>

Thanks.
