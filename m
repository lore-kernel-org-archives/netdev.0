From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH v6 6/9] bgmac: increase rx ring size from 511 to 512
Date: Tue, 14 Apr 2015 07:57:05 +0200
Message-ID: <CACna6rzFhTgK5amx1MdWD3aOcdApix+VyAia0ydXa49fti+kJw@mail.gmail.com>
References: <1428968537-6181-1-git-send-email-nbd@openwrt.org>
	<1428968537-6181-6-git-send-email-nbd@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>,
	Hauke Mehrtens <hauke@hauke-m.de>
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:33526 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751207AbbDNF5G convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 01:57:06 -0400
Received: by lbbzk7 with SMTP id zk7so76151159lbb.0
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 22:57:05 -0700 (PDT)
In-Reply-To: <1428968537-6181-6-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14 April 2015 at 01:42, Felix Fietkau <nbd@openwrt.org> wrote:
> Limiting it to 511 looks like a failed attempt at leaving one descrip=
tor
> empty to allow the hardware to stop processing a buffer that has not
> been prepared yet. However, this doesn't work because this affects th=
e
> total ring size as well
>
> Signed-off-by: Felix Fietkau <nbd@openwrt.org>

Acked-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
