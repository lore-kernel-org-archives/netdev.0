From: Yotam Gigi <yotamg@mellanox.com>
Subject: RE: [PATCH net] act_ife: Add support for machines with
 hard_header_len != mac_len
Date: Fri, 23 Sep 2016 12:28:06 +0000
Message-ID: <DB3PR05MB07646E4305A3AA9BB136CC7AACC80@DB3PR05MB0764.eurprd05.prod.outlook.com>
References: <1474462453-37668-1-git-send-email-yotamg@mellanox.com>
 <20160923.070536.1880911510074184857.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "jhs@mojatatu.com" <jhs@mojatatu.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        mlxsw <mlxsw@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0089.outbound.protection.outlook.com ([104.47.2.89]:29809
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S934340AbcIWMnx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 08:43:53 -0400
In-Reply-To: <20160923.070536.1880911510074184857.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>Sent: Friday, September 23, 2016 2:06 PM
>To: Yotam Gigi <yotamg@mellanox.com>
>Cc: jhs@mojatatu.com; netdev@vger.kernel.org
>Subject: Re: [PATCH net] act_ife: Add support for machines with hard_heade=
r_len
>!=3D mac_len
>
>From: Yotam Gigi <yotamg@mellanox.com>
>Date: Wed, 21 Sep 2016 15:54:13 +0300
>
>> Without that fix, the following could occur:
> ...
>
>I don't think what you are doing in mlxsw is valid.
>
>You can't set hard_header_len arbitrarily, it's the MAC length.
>
>If you need to prepend special headers or whatever, set
>->needed_headroom which is designed for this purpose.

Ok, we will fix that.

Thanks for the comment!

>
>Thanks.
