From: "\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru>
Subject: Re: To GRO or not to GRO...
Date: Sun, 03 Oct 2010 11:18:46 +0400
Message-ID: <152341286090326@web67.yandex.ru>
References: <4CA7BD60.3010501@sauce.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Richard Scobie <richard@sauce.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward2.mail.yandex.net ([77.88.46.7]:37955 "EHLO
	forward2.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752089Ab0JCHZI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Oct 2010 03:25:08 -0400
In-Reply-To: <4CA7BD60.3010501@sauce.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



03.10.2010, 03:17, "Richard Scobie" <richard@sauce.co.nz>:

> In the README for ixgbe-2.1.4, is says:
>
> " Disable GRO when routing/bridging
> =9A=9A=9A---------------------------------
> =9A=9A=9ADue to a known kernel issue, GRO must be turned off when
> routing/bridging.
> =9A=9A=9AGRO can be turned off via ethtool."
>

This information is true for LRO, not GRO.

I believe that this appeared when ixgbe was converted from LRO
to GRO and all occurrences of LRO was blindly replaced by GRO
everywhere.

--
wbr, Oleg.
