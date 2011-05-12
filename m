From: Franco Fichtner <franco@lastsummer.de>
Subject: Re: [PATCH net-next] ethtool: bring back missing comma in netdev_features_strings
Date: Thu, 12 May 2011 11:13:41 +0200
Message-ID: <4DCBA4C5.5040308@lastsummer.de>
References: <4DCB94E6.2020407@lastsummer.de> <BANLkTikH2uY_crot1DRBFZv9ifmvPQeRog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Franco Fichtner <franco@lastsummer.de>,
	Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host64.kissl.de ([213.239.241.64]:36077 "EHLO host64.kissl.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755362Ab1ELJNs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 May 2011 05:13:48 -0400
In-Reply-To: <BANLkTikH2uY_crot1DRBFZv9ifmvPQeRog@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/05/11 10:55, Micha=B3 Miros=B3aw wrote:
> 2011/5/12 Franco Fichtner <franco@lastsummer.de>:
>> I found this while skimming through recent net-next patches.
>> I'm not quite sure if the padding in this struct is correct now.
> Nice catch. But please send the patch inline instead of as an attachm=
ent.

Thanks, but I have a short question. Are the empty strings in
this struct really needed?

        /* NETIF_F_TSO6 */            "tx-tcp6-segmentation",
        /* NETIF_F_FSO */             "tx-fcoe-segmentation",
        "",
        "",

        /* NETIF_F_FCOE_CRC */        "tx-checksum-fcoe-crc",

They seem to have caused this mess in the first place and I would
think they could be removed entirely.

I will resend the patch later today as inline. Sorry about that.


=46ranco
