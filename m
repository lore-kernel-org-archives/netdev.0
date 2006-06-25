From: Adrian Bunk <bunk@stusta.de>
Subject: -git: Why is drivers/net/wan/hdlc_generic.c:hdlc_setup() exported?
Date: Sun, 25 Jun 2006 22:51:38 +0200
Message-ID: <20060625205137.GH23314@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:3090 "HELO
	mailout.stusta.mhn.de") by vger.kernel.org with SMTP
	id S932327AbWFYUvj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Jun 2006 16:51:39 -0400
To: Krzysztof Halasa <khc@pm.waw.pl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 4a31e348e3ecaf54c50240109ac4574b180f8840 added an 
EXPORT_SYMBOL(hdlc_setup) with the justification
   hdlc_setup() is now EXPORTed as per David's request.

Is a usage of this export pending for the near future or could this 
export be reverted until a user is submitted for inclusion?

TIA
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

