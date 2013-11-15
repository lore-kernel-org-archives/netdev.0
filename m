From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: phy: use phy_init_hw instead of open-coding it
Date: Fri, 15 Nov 2013 07:03:04 +0000
Message-ID: <2068298.FXgGSfs2Vb@lenovo>
References: <1384495793-22534-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f53.google.com ([209.85.219.53]:35672 "EHLO
	mail-oa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751523Ab3KOHDI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 02:03:08 -0500
Received: by mail-oa0-f53.google.com with SMTP id k1so3452941oag.40
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 23:03:07 -0800 (PST)
In-Reply-To: <1384495793-22534-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 15 novembre 2013, 06:09:53 Florian Fainelli a =E9crit :
> We already have a helper function which verifies a PHY device driver
> implements a config_init callback, then calls phy_scan_fixups() and
> ultimately calls the config_init callback. Use that instead of open
> coding it.

I did not realize we were in the middle of the merge window, I will re-=
submit=20
once net-next is open again since this is not a fix.
--=20
=46lorian
