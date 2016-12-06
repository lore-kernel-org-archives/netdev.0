From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 1/3] net/flow_dissector: Enable matching on flags
 for TC filter consumers
Date: Tue, 6 Dec 2016 22:51:09 +0200
Message-ID: <CAJ3xEMgkfZ2Fzt7TgtP0BFp7HQ12nf6Yx-Xek332vqBNeN=-OQ@mail.gmail.com>
References: <1481027579-23195-1-git-send-email-ogerlitz@mellanox.com>
 <1481027579-23195-2-git-send-email-ogerlitz@mellanox.com> <20161206124358.GM1984@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>, Roi Dayan <roid@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Tom Herbert <tom@herbertland.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:36809 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752288AbcLFUvK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 15:51:10 -0500
Received: by mail-oi0-f66.google.com with SMTP id u15so42933340oie.3
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 12:51:10 -0800 (PST)
In-Reply-To: <20161206124358.GM1984@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 6, 2016 at 2:43 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Tue, Dec 06, 2016 at 01:32:57PM CET, ogerlitz@mellanox.com wrote:

>> struct flow_keys {
>>+#define FLOW_KEYS_HASH_START_FIELD control
>>       struct flow_dissector_key_control control;
>>-#define FLOW_KEYS_HASH_START_FIELD basic

> How is this hashing related to cls_flower dissections? What am I
> missing?

Oops, this is my bad. I convinced myself that flower dissections will
not work for any field which is not accounted for hash start field, I
was wrong, dropping this patch.
