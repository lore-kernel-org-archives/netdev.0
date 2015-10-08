From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net v3 1/2] fix return of iptunnel_xmit
Date: Thu, 8 Oct 2015 10:33:43 -0700
Message-ID: <CALnjE+pML8uMgEOEEErMd3FNEAqsM=wm5aiFzvKMKShuktm99A@mail.gmail.com>
References: <1444320530-28706-1-git-send-email-aschultz@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:35723 "EHLO
	mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933177AbbJHRdo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 13:33:44 -0400
Received: by ioiz6 with SMTP id z6so65739144ioi.2
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 10:33:43 -0700 (PDT)
In-Reply-To: <1444320530-28706-1-git-send-email-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 8, 2015 at 9:08 AM, Andreas Schultz <aschultz@tpip.net> wrote:
> All users of iptunnel_xmit expect the return value to be the packet
> length on success (>0), negative for a tx error and zero for a tx
> dropped error. In cset 0e6fbc5b6c6218987c93b8c7ca60cf786062899d the
> negative return case was lost.
>
> This bug was introduced when the ip_tunnel_core code was refactored.
>
> Fixes: 0e6fbc5b6c6218987c93b8c7ca60cf786062899d
> Signed-off-by: Andreas Schultz <aschultz@tpip.net>

Thanks for the fix.
Acked-by: Pravin B Shelar <pshelar@nicira.com>
