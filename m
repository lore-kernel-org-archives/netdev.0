From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: [PATCH v2] netfilter: Xtables: idletimer target implementation
Date: Wed, 02 Jun 2010 21:37:15 +0300
Message-ID: <1275503835.1574.0.camel@powerslave>
References: <1275486062-23753-1-git-send-email-luciano.coelho@nokia.com>
	 <alpine.LSU.2.01.1006021708370.27340@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"kaber@trash.net" <kaber@trash.net>, Timo Teras <timo.teras@iki.fi>
To: ext Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1006021708370.27340@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-06-02 at 17:16 +0200, ext Jan Engelhardt wrote:
> On Wednesday 2010-06-02 15:41, Luciano Coelho wrote:
> 
> >+static int __init idletimer_tg_init(void)
> >+{
> >+	int ret;
> >+
> >+	idletimer_tg_kobj = kobject_create_and_add("idletimer",
> >+						   &THIS_MODULE->mkobj.kobj);
> 
> Isn't this going to oops when you compile this module as =y?

Damn, that's true. :(

I'll investigate how to fix this.

-- 
Cheers,
Luca.

