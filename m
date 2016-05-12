From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 0/4] return offloaded stats as default and
 expose original sw start
Date: Thu, 12 May 2016 16:48:04 +0200
Message-ID: <20160512144803.GB2070@nanopsycho.orion>
References: <1463047198-10630-1-git-send-email-jiri@resnulli.us>
 <20160512143645.GE26864@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nogahf@mellanox.com,
	idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
	ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, linville@tuxdriver.com, tgraf@suug.ch,
	gospo@cumulusnetworks.com, sfeldma@gmail.com, sd@queasysnail.net,
	eranbe@mellanox.com, ast@plumgrid.com, edumazet@google.com,
	hannes@stressinduktion.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:38295 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932198AbcELOsM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 10:48:12 -0400
Received: by mail-wm0-f43.google.com with SMTP id g17so140229111wme.1
        for <netdev@vger.kernel.org>; Thu, 12 May 2016 07:48:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160512143645.GE26864@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, May 12, 2016 at 04:36:45PM CEST, andrew@lunn.ch wrote:
>On Thu, May 12, 2016 at 11:59:54AM +0200, Jiri Pirko wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> Until now we had stats functions return SW statistics. However, it makes
>> a lot of sense to return HW stats as default.
>
>Hi Jiri
>
>DSA has always returned the HW stats, i.e, ethtool -S shows the
>counters the switch has for the port.
>
>How do you expect ethtool to handle your change? ethtool -S will print
>both sets? Or are you thinking of adding a new flag?

Ethtool still continues to provide the hw counters. We do the same for
mlxsw driver. No change there.

>
>I'm just trying to understand the big picture, and how it affects DSA,
>if at all.

I didn't check the code, but if dsa provides sw stats by default, it
should be changed to provide hwstats instead. The goal is to keep the
existing applications to see what is going on.
