From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH] bgmac: support Ethernet device on BCM47094 SoC
Date: Fri, 19 Feb 2016 22:26:48 +0100
Message-ID: <CACna6rzGWQBu7ZncdsiHgrnfhgF9bEqZVdX2xiMcAYX7LZ5gbg@mail.gmail.com>
References: <1455691708-24649-1-git-send-email-zajec5@gmail.com>
	<20160219.153729.2239673565372497259.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>,
	Hauke Mehrtens <hauke@hauke-m.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:33504 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1427169AbcBSV0t convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 16:26:49 -0500
Received: by mail-io0-f179.google.com with SMTP id z135so123450774iof.0
        for <netdev@vger.kernel.org>; Fri, 19 Feb 2016 13:26:48 -0800 (PST)
In-Reply-To: <20160219.153729.2239673565372497259.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19 February 2016 at 21:37, David Miller <davem@davemloft.net> wrote:
> From: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
> Date: Wed, 17 Feb 2016 07:48:28 +0100
>
>> It needs very similar workarounds to the one on BCM4707. It was test=
ed
>> on D-Link DIR-885L home router.
>>
>> Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
>
> This patch doesn't apply, I get rejects.

I developed it on top of:
547b9ca Merge branch 'ip-sysctl-namespaceify'
I just rebased in on top of origin/master:
76d13b5 hv_netvsc: add software transmit timestamp support
and it did cleanly. I'm using net-next git tree.

Are you applying it to net-next? It way my intention, sorry if I was
supposed to make it more clear. It depends e.g. on some extra patches,
e.g.:
387b75f bgmac: add helper checking for BCM4707 / BCM53018 chip id
61dba73 bcma: add support for BCM47094
so it's for net-next only.

--=20
Rafa=C5=82
