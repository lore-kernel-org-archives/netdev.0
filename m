From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH v7 7/9] bgmac: simplify dma init/cleanup
Date: Tue, 14 Apr 2015 12:38:38 +0200
Message-ID: <CACna6ry0nB9GL8sSfzshmo1-6U6xayvQdXZUhJSxG8yAZR9NQQ@mail.gmail.com>
References: <1429006082-23489-1-git-send-email-nbd@openwrt.org>
	<1429006082-23489-7-git-send-email-nbd@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>,
	Hauke Mehrtens <hauke@hauke-m.de>
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:37053 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753152AbbDNKij convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 06:38:39 -0400
Received: by igblo3 with SMTP id lo3so10858438igb.0
        for <netdev@vger.kernel.org>; Tue, 14 Apr 2015 03:38:38 -0700 (PDT)
In-Reply-To: <1429006082-23489-7-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14 April 2015 at 12:08, Felix Fietkau <nbd@openwrt.org> wrote:
> Instead of allocating buffers at device init time and initializing
> descriptors at device open, do both at the same time (during open).
> Free all buffers when closing the device.
>
> Signed-off-by: Felix Fietkau <nbd@openwrt.org>

Acked-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
