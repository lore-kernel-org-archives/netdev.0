From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH v6 2/9] bgmac: leave interrupts disabled as long as there
 is work to do
Date: Tue, 14 Apr 2015 07:40:17 +0200
Message-ID: <CACna6rxR1Xf5vHsPz+ykEpDFd5gZgF2rzrb83Rt2A3SGnzhkiw@mail.gmail.com>
References: <1428968537-6181-1-git-send-email-nbd@openwrt.org>
	<1428968537-6181-2-git-send-email-nbd@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>,
	Hauke Mehrtens <hauke@hauke-m.de>
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:34073 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751492AbbDNFkS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 01:40:18 -0400
Received: by iedfl3 with SMTP id fl3so7752938ied.1
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 22:40:17 -0700 (PDT)
In-Reply-To: <1428968537-6181-2-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14 April 2015 at 01:42, Felix Fietkau <nbd@openwrt.org> wrote:
> Always poll rx and tx during NAPI poll instead of relying on the stat=
us
> of the first interrupt. This prevents bgmac_poll from leaving unfinis=
hed
> work around until the next IRQ.
> In my tests this makes bridging/routing throughput under heavy load m=
ore
> stable and ensures that no new IRQs arrive as long as bgmac_poll uses=
 up
> the entire budget.
>
> Signed-off-by: Felix Fietkau <nbd@openwrt.org>

Acked-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
