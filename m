From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re[2]:  [PATCH] netfilter: xt_HMARK: endian bugs
Date: Mon, 14 May 2012 21:32:35 +0200 (CEST)
Message-ID: <dri38gk.79a7b56a47f5dacef2458a1ca42c6deb@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: "Pablo Neira Ayuso" <pablo@netfilter.org>,
	"Jozsef Kadlecsik" <kadlec@blackhole.kfki.hu>,
	"Hans Schillstrom" <hans.schillstrom@ericsson.com>,
	"Jan Engelhardt" <jengelh@inai.de>,
	"kaber@trash.net" <kaber@trash.net>,
	"jengelh@medozas.de" <jengelh@medozas.de>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"dan.carpenter@oracle.com" <dan.carpenter@oracle.com>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org




>---- Original Message ----
>From: Eric Dumazet <eric.dumazet@gmail.com>
>To: "Pablo Neira Ayuso" <pablo@netfilter.org>
>Cc: "Jozsef Kadlecsik" <kadlec@blackhole.kfki.hu>, "Hans Schillstrom" <hans.schillstrom@ericsson.com>, "Jan Engelhardt" <jengelh@inai.de>, "kaber@trash.net" <kaber@trash.net>, "jengelh@medozas.de" <jengelh@medozas.de>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "dan.carpenter@oracle.com" <dan.carpenter@oracle.com>, "hans@schillstrom.com" <hans@schillstrom.com>
>Sent: Mon, May 14, 2012, 9:14 PM
>Subject: Re: [PATCH] netfilter: xt_HMARK: endian bugs
>
>On Mon, 2012-05-14 at 21:02 +0200, Pablo Neira Ayuso wrote:
>
>> IIRC, Hans wants that, in case you have a cluster composed of system
>> with different endianess, the hash mark calculated will be the same
>> in both systems. To ensure that the distribution is consistent with
>> independency of the endianess.
>
>Then jhash() must be audited to make sure its output is OK with this
>requirement.

I'm preparing test on mips & ppc right now to verify that as a first step.

 

