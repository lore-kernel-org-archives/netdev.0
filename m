From: Bastien Nocera <hadess@hadess.net>
Subject: Re: [PATCH 20/22] staging rtl8723bs: Fix indenting errors and an
 off-by-one mistake in core/rtw_mlme_ext.c
Date: Sun, 09 Apr 2017 17:28:37 +0200
Message-ID: <1491751717.10783.21.camel@hadess.net>
References: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
         <20170408160745.14328-21-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
        hdegoede@redhat.com, jes.sorensen@gmail.com
To: Larry Finger <Larry.Finger@lwfinger.net>,
        gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:47864 "EHLO
        slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752360AbdDIP2s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Apr 2017 11:28:48 -0400
Received: from relay7-d.mail.gandi.net (relay7-d.mail.gandi.net [217.70.183.200])
        by slow1-d.mail.gandi.net (Postfix) with ESMTP id D21DA4863ED
        for <netdev@vger.kernel.org>; Sun,  9 Apr 2017 17:28:46 +0200 (CEST)
In-Reply-To: <20170408160745.14328-21-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2017-04-08 at 11:07 -0500, Larry Finger wrote:
>         } else {
> -               for (pstat->aid = 1; pstat->aid <= NUM_STA; pstat->aid++)
> +               for (pstat->aid = 1; pstat->aid < NUM_STA; pstat->aid++)
>                         if (pstapriv->sta_aid[pstat->aid - 1] == NULL)
>                                 break;

why not start at 0 and increment pstat->aid afterwards? Meh.
