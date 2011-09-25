From: Marc Haber <mh+netdev@zugschlus.de>
Subject: Re: [PATCH 1/2] bridge: leave carrier on for empty bridge
Date: Sun, 25 Sep 2011 10:55:40 +0200
Message-ID: <20110925085540.GC32712@torres.zugschlus.de>
References: <20110902172220.830228928@vyatta.com>
 <20110902172247.396753508@vyatta.com>
 <4E614CF7.7030700@gmail.com>
 <20110902151100.327af0bf@nehalam.ftrdhcpuser.net>
 <4E618DCD.5070901@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from torres.zugschlus.de ([85.214.131.164]:33771 "EHLO
	torres.zugschlus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751583Ab1IYIzl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2011 04:55:41 -0400
Received: from mh by torres.zugschlus.de with local (Exim 4.72)
	(envelope-from <mh+netdev@zugschlus.de>)
	id 1R7kUu-0000AX-Lm
	for netdev@vger.kernel.org; Sun, 25 Sep 2011 10:55:40 +0200
Content-Disposition: inline
In-Reply-To: <4E618DCD.5070901@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 03, 2011 at 11:15:41AM +0900, Ang Way Chuang wrote:
> A more ideal solution in this case is to add the option to enabling
> carrier on sysfs and modify libvirtd to turn on the carrier if IPv6 is
> enabled.

I would even do it manually from an init script if that saves me from
having an extra dummy interface on a bridge just to force it up.

>  Since there is no other
>  complain from other user with this setup, I guess nobody actually
>  assigns IPv6 to libvirtd network device at this moment

I do. Daily. And get bitten every time I reboot. A _major_ nuisance.

Greetings
Marc

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Mannheim, Germany  |  lose things."    Winona Ryder | Fon: *49 621 72739834
Nordisch by Nature |  How to make an American Quilt | Fax: *49 3221 2323190
