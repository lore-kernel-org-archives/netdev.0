From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net v2 0/2] Fix tc-ife bugs
Date: Sun, 25 Sep 2016 09:46:25 -0400
Message-ID: <2b01c982-76b7-d380-807c-1fe1df62d285@mojatatu.com>
References: <1474806711-64660-1-git-send-email-yotamg@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Yotam Gigi <yotam.gi@gmail.com>, davem@davemloft.net,
        netdev@vger.kernel.org, yotamg@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f51.google.com ([209.85.214.51]:34907 "EHLO
        mail-it0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966303AbcIYNq2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 09:46:28 -0400
Received: by mail-it0-f51.google.com with SMTP id r192so52922017ita.0
        for <netdev@vger.kernel.org>; Sun, 25 Sep 2016 06:46:28 -0700 (PDT)
In-Reply-To: <1474806711-64660-1-git-send-email-yotamg@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-25 08:31 AM, Yotam Gigi wrote:
> This patch-set contains two bugfixes in the tc-ife action, one fixing some
> random behaviour in encode side, and one fixing the decode side packet
> parsing logic.
>
> Yotam Gigi (2):
>   act_ife: Fix external mac header on encode
>   act_ife: Fix false parsing on decode side
>
>  net/sched/act_ife.c | 9 ++++-----
>  1 file changed, 4 insertions(+), 5 deletions(-)
>

Yotam, did you run the test i proposed? I am worried about the TLV one.
Note:
Encoder includes the length of the TLV header length in the L part.
If you are reaching a conclusion that you need this in the decoding:
+		tlvdata += alen + sizeof(struct meta_tlvhdr);

then very likely whoever is sending that packet is not encoding
correctly.

cheers,
jamal
