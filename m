From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next v2 2/9] net: ipmr: always define mroute_reg_vif_num
Date: Sun, 22 Nov 2015 21:23:21 -0800
Message-ID: <CAHA+R7Pra5DW8UNyPDQKK6Y=J8nz4LvNvmHcsP7pY+-U5NHCKg@mail.gmail.com>
References: <1448117852-4254-1-git-send-email-razor@blackwall.org>
	<1448117852-4254-3-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f169.google.com ([209.85.160.169]:35382 "EHLO
	mail-yk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751173AbbKWFXV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 00:23:21 -0500
Received: by ykba77 with SMTP id a77so225767243ykb.2
        for <netdev@vger.kernel.org>; Sun, 22 Nov 2015 21:23:21 -0800 (PST)
In-Reply-To: <1448117852-4254-3-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 21, 2015 at 6:57 AM, Nikolay Aleksandrov
<razor@blackwall.org> wrote:
> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>
> Before mroute_reg_vif_num was defined only if any of the CONFIG_PIMSM_
> options were set, but that's not really necessary as the size of the
> struct is the same in both cases (checked with pahole, both cases size
> is 3256 bytes) and we can remove some unnecessary ifdefs to simplify the
> code.
>

Not sure if this really simplifies the code, since now
mroute_reg_vif_num is hidden
deeper after your patch and there are still some code under CONFIG_IP_PIMSM.

If you really care about it, how about introducing a helper function
to set and get
mrt->mroute_reg_vif_num?
