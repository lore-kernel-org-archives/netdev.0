From: Bastien Nocera <hadess@hadess.net>
Subject: Re: [PATCH 16/22] staging: rtl8723bs: Fix some indenting problems
 and a potential data overrun
Date: Sun, 09 Apr 2017 17:28:32 +0200
Message-ID: <1491751712.10783.20.camel@hadess.net>
References: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
         <20170408160745.14328-17-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
        hdegoede@redhat.com, jes.sorensen@gmail.com
To: Larry Finger <Larry.Finger@lwfinger.net>,
        gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:55672 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752360AbdDIP2h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Apr 2017 11:28:37 -0400
In-Reply-To: <20170408160745.14328-17-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2017-04-08 at 11:07 -0500, Larry Finger wrote:
> +       if (cam_id >= 0 && cam_id < 32)

Isn't there a constant we could use instead of hard-coding this?
