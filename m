From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: route.c cleanup
Date: Thu, 02 Aug 2012 02:53:35 -0700 (PDT)
Message-ID: <20120802.025335.1899531913021548391.davem@davemloft.net>
References: <1343893753.9299.13.camel@edumazet-glaptop>
	<20120802.014534.1221330015548828529.davem@davemloft.net>
	<1343899420.9299.118.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54103 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751427Ab2HBJxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2012 05:53:38 -0400
In-Reply-To: <1343899420.9299.118.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 02 Aug 2012 11:23:40 +0200

> On Thu, 2012-08-02 at 01:45 -0700, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Thu, 02 Aug 2012 09:49:13 +0200
>> 
>> > From: Eric Dumazet <edumazet@google.com>
>> > 
>> > Remove some unused includes and sysctls after route cache removal.
>> > 
>> > Signed-off-by: Eric Dumazet <edumazet@google.com>
>> 
>> I'm largely against removing the (now pointless) sysctls.
>> 
>> If the settings do nothing, so be it.
>> 
>> But it shouldn't generate warnings and errors during bootup,
>> which is what removing them is going to do.
> 
> Are you referring to a stale key in your /etc/sysctl.conf ?
> 
> I see no distro setting any of the route knob in their sysctl.conf file.

I'm talking about anyone, and people do set these knobs.  I've been
told by people at some large search engine that they, in fact, have
to :-)

> [PATCH v2] ipv4: route.c cleanup
> 
> Remove unused includes after IP cache removal
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

I'll apply this one, thanks.
