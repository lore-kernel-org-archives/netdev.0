From: Yotam Gigi <yotamg@mellanox.com>
Subject: RE: [PATCH net v2 0/2] Fix tc-ife bugs
Date: Mon, 26 Sep 2016 07:01:02 +0000
Message-ID: <DB3PR05MB07641B3E085814C60BC60D64ACCD0@DB3PR05MB0764.eurprd05.prod.outlook.com>
References: <1474806711-64660-1-git-send-email-yotamg@mellanox.com>
 <2b01c982-76b7-d380-807c-1fe1df62d285@mojatatu.com>
 <DB3PR05MB07647722715384C174CC52D2ACCA0@DB3PR05MB0764.eurprd05.prod.outlook.com>
 <098a8df2-aa3e-04a5-143b-a6946c9ece59@mojatatu.com>
 <a57bf1d3-0b6b-91fa-a57d-5b4a17f91959@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Jiri Pirko <jiri@mellanox.com>, Elad Raz <eladr@mellanox.com>,
        mlxsw <mlxsw@mellanox.com>, Roman Mashak <mrv@mojatatu.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
        Yotam Gigi <yotam.gi@gmail.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0049.outbound.protection.outlook.com ([104.47.2.49]:53472
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751059AbcIZIfG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 26 Sep 2016 04:35:06 -0400
In-Reply-To: <a57bf1d3-0b6b-91fa-a57d-5b4a17f91959@mojatatu.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: Jamal Hadi Salim [mailto:jhs@mojatatu.com]
>Sent: Monday, September 26, 2016 3:47 AM
>To: Yotam Gigi <yotamg@mellanox.com>; Yotam Gigi <yotam.gi@gmail.com>;
>davem@davemloft.net; netdev@vger.kernel.org
>Cc: Jiri Pirko <jiri@mellanox.com>; Elad Raz <eladr@mellanox.com>; mlxsw
><mlxsw@mellanox.com>; Roman Mashak <mrv@mojatatu.com>
>Subject: Re: [PATCH net v2 0/2] Fix tc-ife bugs
>
>On 16-09-25 07:17 PM, Jamal Hadi Salim wrote:
>[..]
>>> Do you prefer that I will fix the encode side to encode the whole tlv
>>> header
>>> size instead of fixing the decode side?
>>
>> Yes please - Add NLA_HDRLEN to the dlen on the encode you showed above.

OK. Did it and tested it. Everything seems functional.

>>
>
>And the correct commit it fixes is:
>a823f93750e341bc0d6829a00019435b96830fd4

I can't find this commit. Where is it?=20

Don't you mean that commit: 28a10c426e81afc88514bca8e73affccf850fdf6
with title: "net sched: fix encoding to use real length"?

>
>I removed the padding but also the headerlen when i did
>that. Tested with tc_index which is a u16 was the mistake i made.
>
>cheers,
>jamal
