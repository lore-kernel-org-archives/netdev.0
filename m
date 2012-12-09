From: Eric Dumazet <edumazet@google.com>
Subject: Re: ipgre rss is broken since gro
Date: Sat, 8 Dec 2012 18:01:40 -0800
Message-ID: <CANn89iKE2RxRBWRuXGwjydQKjPLhPbcoZaJS5rcBKbJWWnL4ZQ@mail.gmail.com>
References: <504C9EFCA2D0054393414C9CB605C37F1BFB80B2@SJEXCHMB06.corp.ad.broadcom.com>
	<504C9EFCA2D0054393414C9CB605C37F1BFB80D8@SJEXCHMB06.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:36596 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932228Ab2LICBl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Dec 2012 21:01:41 -0500
Received: by mail-ie0-f176.google.com with SMTP id 13so5307262iea.35
        for <netdev@vger.kernel.org>; Sat, 08 Dec 2012 18:01:41 -0800 (PST)
In-Reply-To: <504C9EFCA2D0054393414C9CB605C37F1BFB80D8@SJEXCHMB06.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 8, 2012 at 3:31 PM, Dmitry Kravkov <dmitry@broadcom.com> wrote:
> Here is the trace for a while:
>
> BUG: unable to handle kernel NULL pointer dereference at           (null)
> IP: [<ffffffff8144f35e>] skb_gro_receive+0xbe/0x5a0

Hi Dmitry

NULL pointer deref probably fixed on net tree (or Linus tree) by

http://git.kernel.org/?p=linux/kernel/git/davem/net.git;a=commit;h=c3c7c254b2e8cd99b0adf288c2a1bddacd7ba255

For the GRO stuff and RSS, I wonder if skbs have a property that makes
them dropped somewhere, you might try drop_monitor / drop_watch
