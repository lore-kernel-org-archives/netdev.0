From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH] forcedeth: add clock gating feature
Date: Tue, 28 Apr 2009 10:48:14 +0200
Message-ID: <200904281048.15663.florian@openwrt.org>
References: <49F5A5A7.4050609@nvidia.com> <20090427122447.a006a21e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ayaz Abdulla <aabdulla@nvidia.com>, manfred@colorfullife.com,
	davem@davemloft.net, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f176.google.com ([209.85.219.176]:55330 "EHLO
	mail-ew0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753080AbZD1IsU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 04:48:20 -0400
Received: by ewy24 with SMTP id 24so406224ewy.37
        for <netdev@vger.kernel.org>; Tue, 28 Apr 2009 01:48:18 -0700 (PDT)
In-Reply-To: <20090427122447.a006a21e.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Le Monday 27 April 2009 21:24:47 Andrew Morton, vous avez =E9crit=A0:
> On Mon, 27 Apr 2009 08:31:35 -0400
>
> Ayaz Abdulla <aabdulla@nvidia.com> wrote:
> > This patch adds support for clock gating the tx/rx engines which is
> > available on certain chipsets.
>
> What are the effects of this patch?  Improved power management?  Fixe=
s
> a user-visible bug?  Something else?

Clock gating is a design technique which improves power consumption by =
only=20
clocking the necessary parts of the chip.

Ayaz do you have any figures on how this patch reduces consumption ?
--=20
Best regards, Florian Fainelli
Email : florian@openwrt.org
http://openwrt.org
-------------------------------
