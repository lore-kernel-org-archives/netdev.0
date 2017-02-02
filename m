From: Yotam Gigi <yotamg@mellanox.com>
Subject: RE: [PATCH net-next 0/2] Extract IFE logic to module
Date: Thu, 2 Feb 2017 11:12:06 +0000
Message-ID: <DB3PR05MB0764ACA552D008CADD09ED40AC4C0@DB3PR05MB0764.eurprd05.prod.outlook.com>
References: <1485871024-41836-1-git-send-email-yotamg@mellanox.com>
 <20170202101641.GA18828@penelope.horms.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "jhs@mojatatu.com" <jhs@mojatatu.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>, Elad Raz <eladr@mellanox.com>,
        Ido Schimmel <idosch@mellanox.com>,
        Roman Mashak <mrv@mojatatu.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0087.outbound.protection.outlook.com ([104.47.0.87]:11008
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751060AbdBBLMK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 2 Feb 2017 06:12:10 -0500
In-Reply-To: <20170202101641.GA18828@penelope.horms.nl>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Simon Horman [mailto:simon.horman@netronome.com]
>Sent: Thursday, February 02, 2017 12:17 PM
>To: Yotam Gigi <yotamg@mellanox.com>
>Cc: jhs@mojatatu.com; davem@davemloft.net; netdev@vger.kernel.org; Jiri Pi=
rko
><jiri@mellanox.com>; Elad Raz <eladr@mellanox.com>; Ido Schimmel
><idosch@mellanox.com>
>Subject: Re: [PATCH net-next 0/2] Extract IFE logic to module
>
>Hi Yotam,
>
>On Tue, Jan 31, 2017 at 03:57:02PM +0200, Yotam Gigi wrote:
>> Extract ife logic from the tc_ife action into an independent module, and
>> make the tc_ife action use it. This way, the ife encapsulation can be us=
ed
>> by other modules other than tc_ife action.
>
>I have no objection to this modularisation but I am curious to know
>if you have a use-case in mind. My understanding is that earlier versions
>of the sample action used IFE but that is not the case in the version that
>was ultimately accepted.

Hi Simon.

You are right that the patches were done for the former version of the samp=
le
classifier, and there are not required for the current version. We don't ha=
ve
current use-case in mind, but I did send the patches because I think it can=
 help
others, or us in the future.
