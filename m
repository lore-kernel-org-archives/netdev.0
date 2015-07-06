From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH] ip_tunnel: fix ipv4 pmtu check to honor inner ip header df
Date: Mon, 6 Jul 2015 13:26:05 -0700
Message-ID: <CALnjE+qw-UirLcfQJyVciqbVPN5NJXD9vf4m3po7zicY7Dn8DA@mail.gmail.com>
References: <1436171750-6029-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: =?UTF-8?Q?Timo_Ter=C3=A4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:37083 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181AbbGFU0F convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 16:26:05 -0400
Received: by igau2 with SMTP id u2so20761194iga.0
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2015 13:26:05 -0700 (PDT)
In-Reply-To: <1436171750-6029-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 6, 2015 at 1:35 AM, Timo Ter=C3=A4s <timo.teras@iki.fi> wro=
te:
> Frag needed should be sent only if the inner header asked
> to not fragment. Currently fragmentation is broken if the
> tunnel has df set. The tunnel's df needs to be still checked
> to update internally the pmtu cache.
>
> This got broken in commit 23a3647bc4f93bac and this fixes
> the pmtu check back to the way it was.
>
> Fixes: 23a3647bc4f93bac ("ip_tunnels: Use skb-len to PMTU check.")
> Cc: Pravin B Shelar <pshelar@nicira.com>

Patch looks good, But commit msg is missing Signed-off-by: tag.
