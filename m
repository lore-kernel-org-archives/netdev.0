From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH V2] brcmfmac: fix possible buffer overflow in brcmf_cfg80211_mgmt_tx()
Date: Fri, 7 Jul 2017 13:11:42 -0700
Message-ID: <CA+55aFxGKy7DP4VDEcBxUCbUyyd+hmH4r=JHqdpTxxFi7S_rDQ@mail.gmail.com>
References: <1499458154-18358-1-git-send-email-arend.vanspriel@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Network Development <netdev@vger.kernel.org>,
        Linux Wireless List <linux-wireless@vger.kernel.org>
To: Arend van Spriel <arend.vanspriel@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:34198 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751089AbdGGULn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2017 16:11:43 -0400
In-Reply-To: <1499458154-18358-1-git-send-email-arend.vanspriel@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 7, 2017 at 1:09 PM, Arend van Spriel
<arend.vanspriel@broadcom.com> wrote:
> Now I signed off on the patch although formally I suppose Linus should
> sign it off.

You can certainly consider it

   Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

but I really don't need the authorship (or resulting sign-off
requirement) because multiple people ended up sending in very similar
patches.

All the real work was in actually finding the issue.

                  Linus
