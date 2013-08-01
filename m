From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] net/fec: Don't let ndo_start_xmit return NETDEV_TX_BUSY
 without link
Date: Wed, 31 Jul 2013 22:25:11 -0400
Message-ID: <1375323911.5418.48.camel@gandalf.local.home>
References: <1375176580-7368-1-git-send-email-u.kleine-koenig@pengutronix.de>
	 <20130730.160530.831845971567683172.davem@davemloft.net>
	 <20130731081649.GA1754@pengutronix.de>
	 <20130731.115101.340503855490269301.davem@davemloft.net>
	 <9848F2DB572E5649BA045B288BE08FBE015E3A69@039-SN2MPN1-023.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"u.kleine-koenig@pengutronix.de" <u.kleine-koenig@pengutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Estevam Fabio-R49496 <r49496@freescale.com>,
	Li Frank-B20596 <B20596@freescale.com>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>,
	"hector.palacios@digi.com" <hector.palacios@digi.com>,
	"tim.sander@hbm.com" <tim.sander@hbm.com>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"florian@openwrt.org" <florian@openwrt.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>
To: Duan Fugang-B38611 <B38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.122]:17239 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751777Ab3HACZO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 22:25:14 -0400
In-Reply-To: <9848F2DB572E5649BA045B288BE08FBE015E3A69@039-SN2MPN1-023.039d.mgd.msft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-08-01 at 02:01 +0000, Duan Fugang-B38611 wrote:

> > This is not an official tag recognized by patchwork, he should say:
> >
> > Acked-by: Fugang Duan <B38611@freescale.com>
> > Tested-by: Fugang Duan <B38611@freescale.com>
> 
> I see Linux kernel trees have many non-official tag such as: Acked-and-tested-by.

Yeah, that was done before, but it's been stated several times that we
want to conform to one tag per line. Makes parsing with tools much
easier.

-- Steve
