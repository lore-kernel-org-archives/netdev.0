From: Pavel Belous <pavel.s.belous@gmail.com>
Subject: Re: [PATCH] net: aquantia: atlantic: use new api ethtool_{get|set}_link_ksettings
Date: Mon, 30 Jan 2017 19:13:02 +0300
Message-ID: <1485792782-5634-1-git-send-email-pavel.s.belous@gmail.com>
References: <1485610661-21099-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:33575 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932462AbdA3QXV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 11:23:21 -0500
Received: by mail-lf0-f67.google.com with SMTP id x1so31878323lff.0
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 08:22:27 -0800 (PST)
In-Reply-To: <1485610661-21099-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Philippe,

thanks you for your patch, it looks good.
One improvement - could you please add support/advertising for TP?

>+	supported |= SUPPORTED_Autoneg;
need:
	supported |= SUPPORTED_TP;


>+	advertising = (self->aq_nic_cfg.is_autoneg) ?
> 							ADVERTISED_Autoneg : 0U;

need:
	advertising |= ADVERTISED_TP;


Thank you.
