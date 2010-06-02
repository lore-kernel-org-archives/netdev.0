From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: [PATCH v2] netfilter: Xtables: idletimer target implementation
Date: Wed, 02 Jun 2010 22:05:53 +0300
Message-ID: <1275505553.2797.2.camel@powerslave>
References: <1275486062-23753-1-git-send-email-luciano.coelho@nokia.com>
	 <alpine.LSU.2.01.1006021708370.27340@obet.zrqbmnf.qr>
	 <1275503835.1574.0.camel@powerslave>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"kaber@trash.net" <kaber@trash.net>, Timo Teras <timo.teras@iki.fi>
To: ext Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:53716 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932880Ab0FBTGI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 15:06:08 -0400
In-Reply-To: <1275503835.1574.0.camel@powerslave>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-06-02 at 20:37 +0200, Coelho Luciano (Nokia-D/Helsinki)
wrote:
> On Wed, 2010-06-02 at 17:16 +0200, ext Jan Engelhardt wrote:
> > On Wednesday 2010-06-02 15:41, Luciano Coelho wrote:
> > 
> > >+static int __init idletimer_tg_init(void)
> > >+{
> > >+	int ret;
> > >+
> > >+	idletimer_tg_kobj = kobject_create_and_add("idletimer",
> > >+						   &THIS_MODULE->mkobj.kobj);
> > 
> > Isn't this going to oops when you compile this module as =y?
> 
> Damn, that's true. :(
> 
> I'll investigate how to fix this.

Would it be too hacky to force it to be a module (ie. add "depends on m"
in Kconfig)?

Besides /sys/module/xt_IDLETIMER and /sys/class/net, which we have
already discarded, I can't find any other place that would make sense to
add the idletimer in the kernel object hierarchy...


-- 
Cheers,
Luca.

