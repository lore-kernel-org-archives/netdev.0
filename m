From: olof@lixom.net (Olof Johansson)
Subject: Re: [PATCH v3] [8/10] pasemi_mac: Add msglevel support and "pasemi_mac_debug" module param
Date: Tue, 8 May 2007 00:33:27 -0500
Message-ID: <20070508053327.GB14152@lixom.net>
References: <20070428203624.GA4331@lixom.net> <20070428203803.GI4331@lixom.net> <46400490.4080606@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:32963 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754728AbXEHGIo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 02:08:44 -0400
Content-Disposition: inline
In-Reply-To: <46400490.4080606@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 08, 2007 at 01:03:12AM -0400, Jeff Garzik wrote:
> Olof Johansson wrote:
> >+	/* Enable most messages by default */
> >+	if (pasemi_mac_debug > 0)
> >+		mac->msg_enable = DEFAULT_MSG_ENABLE;
> >+	else
> >+		mac->msg_enable = pasemi_mac_debug;
> >+
> 
> 
> use netif_msg_init()

Thanks. It's also needlessly verbose to have the module parameter that
long. Other drivers just use "debug", so I switched to the same.


-Olof
