From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: [Linux-v4.4-LTS] ppp: Backport of rtnetlink device handling
Date: Mon, 4 Jan 2016 08:47:30 +0100
Message-ID: <CA+icZUXJwvr7k1xrEy1w_Fw4D3V-LA7dKfDa0gxHHmNu3XY=kw@mail.gmail.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f48.google.com ([209.85.213.48]:35559 "EHLO
	mail-vk0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751118AbcADHrb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 02:47:31 -0500
Received: by mail-vk0-f48.google.com with SMTP id k1so118263262vkb.2
        for <netdev@vger.kernel.org>; Sun, 03 Jan 2016 23:47:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Guillaume,

which patches do I need to backport "ppp: rtnetlink device handling"
to Linux v4.4 which will be a LongTerm-Supported (LTS) Linux-kernel
[0]?

I tried [1] and [2] on top of recent net-next Git tree which will be
in Linux v4.5.
Currently, your patches are not included in net-next.git#master.

In the thread "[net-next] ppp: rtnetlink device handling" [4] you
explained the benefits and use-case etc.

Checking with git-log shows me these commits...

$ git log --oneline --no-merges v4.4-rc8.. drivers/net/ppp net/l2tp
19e8c5713e78 l2tp: rely on ppp layer for skb scrubbing
645eee4eba45 ppp: implement rtnetlink device handling
3a9bce0ae138 ppp: define reusable device creation functions
69d9728d00c7 ppp: declare ppp devices as enumerated interfaces
94dbffe16eb1 ppp: define "ppp" device type
681b4d88ad8e pppox: use standard module auto-loading feature
a8acce6aa584 ppp: remove PPPOX_ZOMBIE socket state
8734e485fed5 ppp: don't set sk_state to PPPOX_ZOMBIE in pppoe_disc_rcv()

...is that sufficient for a backport?

Where there changes to net(-nex)t infrastructure which I need as well?

Thanks in advance.

Kind regards,
- Sedat -

[0] https://www.kernel.org/category/releases.html
[1] https://patchwork.ozlabs.org/patch/560702/
[2] https://patchwork.ozlabs.org/patch/560703/
[3] https://patchwork.ozlabs.org/patch/561540/
[4] http://marc.info/?t=145154824300001&r=1&w=2
