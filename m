From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net:ethernet:aquantia:atlantic: Fix driver name
 reported by ethtool
Date: Wed, 03 May 2017 14:10:21 -0400 (EDT)
Message-ID: <20170503.141021.1943670302532328453.davem@davemloft.net>
References: <06ae22333f8b032e21628389a0c5e33075e5082e.1493829200.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, darcari@redhat.com
To: Pavel.Belous@aquantia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40424 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751159AbdECSKX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 14:10:23 -0400
In-Reply-To: <06ae22333f8b032e21628389a0c5e33075e5082e.1493829200.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <Pavel.Belous@aquantia.com>
Date: Wed,  3 May 2017 21:06:04 +0300

> From: Pavel Belous <pavel.belous@aquantia.com>
> 
> The command "ethtool -i ethX" should display driver name (driver: atlantic)
> instead vendor name (driver: aquantia).
> 
> Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>

I'd like to ask you to please use a more appropriate subsystem prefix
in your patches.

First of all, if there are mutliple subsystem tags, separate them with spaces.

But in this case, purely "aquantia: " is sufficient.

Please resubmit this with that fixed up, thank you.
