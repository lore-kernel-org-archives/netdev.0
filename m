From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [RFC] netfilter: WIP: Xtables idletimer target implementation
Date: Mon, 31 May 2010 21:51:17 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1005312143470.23758@obet.zrqbmnf.qr>
References: <1274993689-23928-1-git-send-email-luciano.coelho@nokia.com>  <alpine.LSU.2.01.1005280057190.14077@obet.zrqbmnf.qr>  <1275024304.3754.45.camel@powerslave>  <alpine.LSU.2.01.1005281001550.11570@obet.zrqbmnf.qr>  <1275040724.24490.121.camel@chilepepper>
  <4C03DCF3.1080001@trash.net> <1275333179.11744.23.camel@powerslave>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ext Patrick McHardy <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Timo Teras <timo.teras@iki.fi>
To: Luciano Coelho <luciano.coelho@nokia.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1275333179.11744.23.camel@powerslave>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Monday 2010-05-31 21:12, Luciano Coelho wrote:
>
>I considered this option, but then I didn't find a proper place where to
>include the attribute in sysfs, since I cannot add it as part of the
>interface (eg. /sys/class/net/wlan0/idletimer) as I was doing before.

You couldn't have done that before either, because the interface name
in ipt_ip may refer to an interface that does not exist at all times.

>The other option would be to make the idletimer as part of the
>xt_IDLETIMER module object in sysfs
>(ie. /sys/module/xt_IDLETIMER/<user_supplied_name>), but it looks out of
>place.

I like it. It follows /proc/net/xt_{hashlimit,recent}/<user_supplied_name>.

>And I think adding it as /sys/class/net/idletimer is most likely
>out of the question.

It follows /sys/class/leds/...


I'm impartial though.
