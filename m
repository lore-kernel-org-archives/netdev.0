From: Timo Teras <timo.teras@iki.fi>
Subject: Re: [PATCH net-next 0/6] ipv4 fixes for dmvpn
Date: Tue, 28 May 2013 09:33:15 +0300
Message-ID: <20130528093315.2a61b855@vostro>
References: <1369653376-4731-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f177.google.com ([209.85.215.177]:62169 "EHLO
	mail-ea0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933008Ab3E1Gbf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 02:31:35 -0400
Received: by mail-ea0-f177.google.com with SMTP id q14so4299604eaj.8
        for <netdev@vger.kernel.org>; Mon, 27 May 2013 23:31:34 -0700 (PDT)
In-Reply-To: <1369653376-4731-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

On Mon, 27 May 2013 14:16:10 +0300
Timo Ter=C3=A4s <timo.teras@iki.fi> wrote:

> Collection of pending fixes which mostly hit DMVPN setups, but some
> are doing good to generic setups too.
>=20
> Patches 1 & 2 fix the NOARP flag change to flush nud NOARP entries
> from ARP cache. The only change from previous send is updating the
> commit message per request, and adding Ben's Acked-By.

I agree with Jiri, that these can be deferred until he gets the
notifier improvements done.

> Patch 3 reworks IPsec PMTU propagation to be less invasive, and fixes
> certain subtle caching issues.
>=20
> Patch 4 and 5 are performance improvements. Both are especially usefu=
l
> on dmvpn setups, but the latter patch helps general setups too.

Seems you deferred also these patches 3-5. However, these are not
dependant on the first two patches. Could these be taken a look at?

These would be the patchwork items:
http://patchwork.ozlabs.org/patch/246579/
http://patchwork.ozlabs.org/patch/246575/
http://patchwork.ozlabs.org/patch/246577/

Or should I resubmit them later?

Thanks,
 Timo
