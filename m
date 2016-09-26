From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net v2 0/2] Fix tc-ife bugs
Date: Sun, 25 Sep 2016 20:47:12 -0400
Message-ID: <a57bf1d3-0b6b-91fa-a57d-5b4a17f91959@mojatatu.com>
References: <1474806711-64660-1-git-send-email-yotamg@mellanox.com>
 <2b01c982-76b7-d380-807c-1fe1df62d285@mojatatu.com>
 <DB3PR05MB07647722715384C174CC52D2ACCA0@DB3PR05MB0764.eurprd05.prod.outlook.com>
 <098a8df2-aa3e-04a5-143b-a6946c9ece59@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@mellanox.com>, Elad Raz <eladr@mellanox.com>,
        mlxsw <mlxsw@mellanox.com>, Roman Mashak <mrv@mojatatu.com>
To: Yotam Gigi <yotamg@mellanox.com>, Yotam Gigi <yotam.gi@gmail.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:36760 "EHLO
        mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941386AbcIZArQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 20:47:16 -0400
Received: by mail-io0-f180.google.com with SMTP id m79so167887993ioo.3
        for <netdev@vger.kernel.org>; Sun, 25 Sep 2016 17:47:15 -0700 (PDT)
In-Reply-To: <098a8df2-aa3e-04a5-143b-a6946c9ece59@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-25 07:17 PM, Jamal Hadi Salim wrote:
[..]
>> Do you prefer that I will fix the encode side to encode the whole tlv
>> header
>> size instead of fixing the decode side?
>
> Yes please - Add NLA_HDRLEN to the dlen on the encode you showed above.
>

And the correct commit it fixes is:
a823f93750e341bc0d6829a00019435b96830fd4

I removed the padding but also the headerlen when i did
that. Tested with tc_index which is a u16 was the mistake i made.

cheers,
jamal
