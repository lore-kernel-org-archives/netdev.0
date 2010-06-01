From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: [RFC] netfilter: WIP: Xtables idletimer target implementation
Date: Tue, 01 Jun 2010 21:41:35 +0300
Message-ID: <1275417695.14585.4.camel@powerslave>
References: <1274993689-23928-1-git-send-email-luciano.coelho@nokia.com>
	 <alpine.LSU.2.01.1005280057190.14077@obet.zrqbmnf.qr>
	 <1275024304.3754.45.camel@powerslave>
	 <alpine.LSU.2.01.1005281001550.11570@obet.zrqbmnf.qr>
	 <1275040724.24490.121.camel@chilepepper>  <4C03DCF3.1080001@trash.net>
	 <1275333179.11744.23.camel@powerslave>
	 <alpine.LSU.2.01.1005312143470.23758@obet.zrqbmnf.qr>
	 <1275417197.14585.2.camel@powerslave>
	 <alpine.LSU.2.01.1006012035350.15461@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ext Patrick McHardy <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Timo Teras <timo.teras@iki.fi>
To: ext Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:50673 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752439Ab0FASsN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 14:48:13 -0400
In-Reply-To: <alpine.LSU.2.01.1006012035350.15461@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-06-01 at 20:38 +0200, ext Jan Engelhardt wrote:
> On Tuesday 2010-06-01 20:33, Luciano Coelho wrote:
> >On Mon, 2010-05-31 at 21:51 +0200, ext Jan Engelhardt wrote:
> >> On Monday 2010-05-31 21:12, Luciano Coelho wrote:
> >> >
> >> >I considered this option, but then I didn't find a proper place where to
> >> >include the attribute in sysfs, since I cannot add it as part of the
> >> >interface (eg. /sys/class/net/wlan0/idletimer) as I was doing before.
> >> 
> >> You couldn't have done that before either, because the interface name
> >> in ipt_ip may refer to an interface that does not exist at all times.
> >> 
> >> >The other option would be to make the idletimer as part of the
> >> >xt_IDLETIMER module object in sysfs
> >> >(ie. /sys/module/xt_IDLETIMER/<user_supplied_name>), but it looks out of
> >> >place.
> >> 
> >> I like it. It follows /proc/net/xt_{hashlimit,recent}/<user_supplied_name>.
> >
> >I'm starting to like this more and more too, as my code is getting much
> >smaller ;)
> >
> >One quick question, though.  Do you have any ideas on how I can make
> >sure that the user doesn't supply the same name twice (ie. two rules
> >with the same user_supplied_name)?
> 
> What's so bad about multiple rules being able to reset the timer?

Ahhmm... Nothing! Thank you, I think I'm getting code-blind :)

-- 
Cheers,
Luca.

