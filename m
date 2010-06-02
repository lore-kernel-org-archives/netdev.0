From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH v2] netfilter: Xtables: idletimer target implementation
Date: Wed, 2 Jun 2010 17:16:02 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1006021708370.27340@obet.zrqbmnf.qr>
References: <1275486062-23753-1-git-send-email-luciano.coelho@nokia.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	kaber@trash.net, Timo Teras <timo.teras@iki.fi>
To: Luciano Coelho <luciano.coelho@nokia.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1275486062-23753-1-git-send-email-luciano.coelho@nokia.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wednesday 2010-06-02 15:41, Luciano Coelho wrote:

>+static int __init idletimer_tg_init(void)
>+{
>+	int ret;
>+
>+	idletimer_tg_kobj = kobject_create_and_add("idletimer",
>+						   &THIS_MODULE->mkobj.kobj);

Isn't this going to oops when you compile this module as =y?

