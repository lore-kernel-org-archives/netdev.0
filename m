From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Mon, 25 Jun 2007 13:47:41 -0700 (PDT)
Message-ID: <20070625.134741.129320846.davem@davemloft.net>
References: <1182440388.5017.31.camel@localhost>
	<1182475614.30969.102.camel@debian.sh.intel.com>
	<1182790051.5184.29.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yi.zhu@intel.com, kaber@trash.net, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35054
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754159AbXFYUrX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 16:47:23 -0400
In-Reply-To: <1182790051.5184.29.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Mon, 25 Jun 2007 12:47:31 -0400

> On Fri, 2007-22-06 at 09:26 +0800, Zhu Yi wrote:
> > We don't have THL and THH in our driver. They are what you suggested.
> > The queue wakeup number is 1/4 of the ring size.
> 
> So how did you pick 1/4? Experimentation? If you look at tg3 its much
> higher for example.

tg3 uses 1/4:

#define TG3_TX_WAKEUP_THRESH(tp)		((tp)->tx_pending / 4)

tp->tx_pending is the current configured ring size, configurable
via ethtool.
