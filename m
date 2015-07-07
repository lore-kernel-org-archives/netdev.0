From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net,v2] ip_tunnel: fix ipv4 pmtu check to honor inner ip
 header df
Date: Tue, 7 Jul 2015 15:07:46 -0700
Message-ID: <CALnjE+pOsCSyZu1=6kNN5ejbWbxHoNjvy5kdY_K0EuBpoFqJTQ@mail.gmail.com>
References: <20150707033906.GF1173@brightrain.aerifal.cx>
	<1436247253-6466-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: =?UTF-8?Q?Timo_Ter=C3=A4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:33231 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932713AbbGGWHr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 18:07:47 -0400
Received: by ieru20 with SMTP id u20so598350ier.0
        for <netdev@vger.kernel.org>; Tue, 07 Jul 2015 15:07:46 -0700 (PDT)
In-Reply-To: <1436247253-6466-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 6, 2015 at 10:34 PM, Timo Ter=C3=A4s <timo.teras@iki.fi> wr=
ote:
> Frag needed should be sent only if the inner header asked
> to not fragment. Currently fragmentation is broken if the
> tunnel has df set, but df was not asked in the original
> packet. The tunnel's df needs to be still checked to update
> internally the pmtu cache.
>
> Commit 23a3647bc4f93bac broke it, and this commit fixes
> the ipv4 df check back to the way it was.
>
> Fixes: 23a3647bc4f93bac ("ip_tunnels: Use skb-len to PMTU check.")
> Cc: Pravin B Shelar <pshelar@nicira.com>
> Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
> ---
> Should go to -stable queues (3.12.y and newer).
>
> v2: revised commit message wording a bit, and added
> signed-off-by line that was forgotten accidentally.
>

Acked-by: Pravin B Shelar <pshelar@nicira.com>
