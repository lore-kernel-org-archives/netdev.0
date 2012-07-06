From: Christian Riesch <christian.riesch@omicron.at>
Subject: Re: [PATCH 0/4] Add a driver for the ASIX AX88172A
Date: Fri, 6 Jul 2012 13:51:22 +0200
Message-ID: <CABkLObp5=mJ9w4H-v61yuHBOu_D2nnsMpWoy-MJ4TunDKSsMFg@mail.gmail.com>
References: <1341574388-7464-1-git-send-email-christian.riesch@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Oliver Neukum <oneukum@suse.de>,
	Eric Dumazet <edumazet@google.com>,
	Allan Chou <allan@asix.com.tw>,
	Mark Lord <kernel@teksavvy.com>,
	Grant Grundler <grundler@chromium.org>,
	Ming Lei <tom.leiming@gmail.com>,
	Michael Riesch <michael@riesch.at>,
	Christian Riesch <christian.riesch@omicron.at>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:58081 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030257Ab2GFLvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 07:51:22 -0400
Received: by gglu4 with SMTP id u4so8467074ggl.19
        for <netdev@vger.kernel.org>; Fri, 06 Jul 2012 04:51:22 -0700 (PDT)
In-Reply-To: <1341574388-7464-1-git-send-email-christian.riesch@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 6, 2012 at 1:33 PM, Christian Riesch
<christian.riesch@omicron.at> wrote:
> Hi,
>
> this patch adds a driver for the ASIX AX88172A USB 2.0 to 10/100M
> Fast Ethernet Controller.
>
> Although this chip is already supported by the AX88772 code in
> drivers/net/usb/asix.c, I submit a new driver since the existing
> driver lacks an important feature: It only supports an
> Ethernet connection using the internal PHY embedded in the AX88172A.

Sorry, I forgot to mention the features added by the new driver:
- support for an external PHY connected to the AX88172A
- uses phylib

Regards, Christian
