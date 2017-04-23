From: Maksim Salau <maksim.salau@gmail.com>
Subject: Re: [PATCH] net: can: usb: gs_usb: Fix buffer on stack
Date: Sun, 23 Apr 2017 20:18:03 +0300
Message-ID: <20170423201803.59394deb@gmail.com>
References: <20170422165626.10534-1-maksim.salau@gmail.com>
        <CAOMZO5DLdR00FY01r2z=RvSrn4vNEZ+Z3OS0KWB95DGt=3fh2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Wolfgang Grandegger <wg@grandegger.com>,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        Maximilian Schneider <max@schneidersoft.net>,
        Hubert Denkmair <hubert@denkmair.de>,
        Wolfram Sang <wsa-dev@sang-engineering.com>,
        Ethan Zonca <e@ethanzonca.com>, linux-can@vger.kernel.org,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:35956 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1162385AbdDWRSL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2017 13:18:11 -0400
In-Reply-To: <CAOMZO5DLdR00FY01r2z=RvSrn4vNEZ+Z3OS0KWB95DGt=3fh2w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > +       struct gs_identify_mode *imode = NULL;  
> 
> No need to assign imode to NULL here.

Thanks, Fabio.

I'll fix this in v2.

Maksim
