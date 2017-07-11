From: Marc Duponcheel <marc@offline.be>
Subject: Re: meson-gxbb-p200 4.12.0 network TCP transfer stalls
Date: Tue, 11 Jul 2017 02:34:59 +0200
Message-ID: <20170711003459.GC24423@offline.be>
References: <20170708005542.GA20515@offline.be>
 <20170710234845.GA24423@offline.be>
Reply-To: Marc Duponcheel <marc@offline.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marc Duponcheel <marc@offline.be>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server.offline.be ([79.132.231.86]:51976 "EHLO mail.offline.be"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750926AbdGKA1P (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Jul 2017 20:27:15 -0400
Content-Disposition: inline
In-Reply-To: <20170710234845.GA24423@offline.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 I use NBD for fast building and savif SD card and, sadly, the TV box crashes after few min of building

On 2017 Jul 11, Marc Duponcheel wrote:
>  FYI
> 
> I changed 4.12.0 drivers/net/phy/realtek.c RTL8211F code to equal the
> 3.14.29 amlogic/ethernet/phy/am_realtek.c code and now the networking
> works without TCP stalls.
> 
> I don't say below patch should be considered mainstream (as maybe some
> 4.12.0 rtl8211f_config_init code should not be removed) but sure
> someone could figure out what best patch is...
