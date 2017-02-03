From: Roman Mashak <mrv@mojatatu.com>
Subject: Re: [PATCH 2/3] net: Introduce ife encapsulation module
Date: Fri, 03 Feb 2017 08:31:14 -0500
Message-ID: <85k297o0yl.fsf@mojatatu.com>
References: <1485955803-65065-1-git-send-email-yotamg@mellanox.com>
        <1485955803-65065-3-git-send-email-yotamg@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: jhs@mojatatu.com, davem@davemloft.net, netdev@vger.kernel.org,
        eladr@mellanox.com, jiri@mellanox.com
To: Yotam Gigi <yotamg@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:34885 "EHLO
        mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753402AbdBCNbR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 08:31:17 -0500
Received: by mail-io0-f172.google.com with SMTP id j18so17280363ioe.2
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 05:31:17 -0800 (PST)
In-Reply-To: <1485955803-65065-3-git-send-email-yotamg@mellanox.com> (Yotam
        Gigi's message of "Wed, 1 Feb 2017 15:30:02 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yotam Gigi <yotamg@mellanox.com> writes:

> This module is responsible for the ife encapsulation protocol
> encode/decode logics. That module can:
>  - ife_encode: encode skb and reserve space for the ife meta header
>  - ife_decode: decode skb and extract the meta header size
>  - ife_tlv_meta_encode - encodes one tlv entry into the reserved ife
>    header space.
>  - ife_tlv_meta_decode - decodes one tlv entry from the packet
>  - ife_tlv_meta_next - advance to the next tlv
>
> Reviewed-by: Jiri Pirko <jiri@mellanox.com>
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>

Signed-off-by: Roman Mashak <mrv@mojatatu.com>

-- 
Roman Mashak
