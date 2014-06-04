From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH] gianfar: Call netif_carrier_off() prior to registration
Date: Tue, 3 Jun 2014 23:51:32 -0300
Message-ID: <CAOMZO5C6FU-8ggwtxmi=PyHVKLu1CGPzFK0dCENkd=750gQoeg@mail.gmail.com>
References: <1401836138-13253-1-git-send-email-festevam@gmail.com>
	<CAGVrzcaK6n53=W+ixN9Hibc3oOgEGe7FFMVTwWzUNOyL3jotfw@mail.gmail.com>
	<20140603.190526.241247147331404487.davem@davemloft.net>
	<538E877C.7080509@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f175.google.com ([209.85.128.175]:48496 "EHLO
	mail-ve0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752110AbaFDCvd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 22:51:33 -0400
Received: by mail-ve0-f175.google.com with SMTP id jw12so8057006veb.34
        for <netdev@vger.kernel.org>; Tue, 03 Jun 2014 19:51:32 -0700 (PDT)
In-Reply-To: <538E877C.7080509@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 3, 2014 at 11:42 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:

> Not at all, I think this patch is fine. If Fabio wants/can audit the other
> Freescale drivers I think this should be beneficial.

Yes, I have checked the other Freescale net drivers and the only one
with this particular problem was gianfar.
