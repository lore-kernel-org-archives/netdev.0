From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [RFC: 2.6 patch] net/irda/irias_object.c: remove unused exports
Date: Sun, 16 Apr 2006 19:46:50 +0200
Message-ID: <1145209616.3809.14.camel@laptopd505.fenrus.org>
References: <20060414114446.GL4162@stusta.de>
	 <20060414164203.GA24146@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@stusta.de>, Samuel.Ortiz@nokia.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:59589 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1750773AbWDPRuV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Apr 2006 13:50:21 -0400
To: jt@hpl.hp.com
In-Reply-To: <20060414164203.GA24146@bougret.hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> 	Personally, I don't see what this patch buy us...

all the unused exports in the kernel together make a binary kernel 100Kb
bigger. It's a case of a lot of little steps I suppose (each export
taking like 100 to 150 bytes depending on the size of the function name)

