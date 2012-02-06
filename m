From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH] bcma: don't fail for bad SPROM CRC
Date: Mon, 6 Feb 2012 18:08:51 +0100
Message-ID: <CACna6rwqO73a0G=AQhTVCm=KeLRgjgc5ohJ_B8Z4T9Y-6ZTwMg@mail.gmail.com>
References: <1328534801-3477-1-git-send-email-rydberg@euromail.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>
To: Henrik Rydberg <rydberg@euromail.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:33505 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755337Ab2BFRIw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 12:08:52 -0500
Received: by wgbdt10 with SMTP id dt10so6435041wgb.1
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2012 09:08:51 -0800 (PST)
In-Reply-To: <1328534801-3477-1-git-send-email-rydberg@euromail.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/2/6 Henrik Rydberg <rydberg@euromail.se>:
> The brcmsmac driver is now checking the bcma SPROM CRCs, leaving some
> chipsets unrecognized that were functional prior to the switch. In
> particular, the current code bails out on recent Macbooks. This patch
> simply ignores the outcome of the CRC check, with the argument that a=
n
> unrecognized SPROM should be treated similarly to a non-existing one.

Have you maybe tried to look at the real solution?

--=20
Rafa=C5=82
