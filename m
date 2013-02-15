From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 1/1] drivers: net: davinci_cpdma: acknowledge
 interrupt properly
Date: Fri, 15 Feb 2013 12:18:59 -0800
Message-ID: <1360959539.21068.5.camel@joe-AO722>
References: <1360866406-17261-1-git-send-email-mugunthanvnm@ti.com>
	 <20130215.150506.499818568035818118.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:34794 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751049Ab3BOUTA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Feb 2013 15:19:00 -0500
In-Reply-To: <20130215.150506.499818568035818118.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-02-15 at 15:05 -0500, David Miller wrote:
> From: Mugunthan V N <mugunthanvnm@ti.com>
> Date: Thu, 14 Feb 2013 23:56:46 +0530
> 
> > +enum {
> > +     CPDMA_EOI_RX_THRESH = 0,
> > +     CPDMA_EOI_RX,
> > +     CPDMA_EOI_TX,
> > +     CPDMA_EOI_MISC,
> > +};
> 
> Do not use enumerations for hardware register values, which must be
> exact, otherwise you are potentially going to succumb to the vagaries
> of C language enumeration value assignment.

Vagaries?

In what way is c enumeration (6.7.2.2) vague?
char vs int?  Isn't smaller mostly better?

Concern about possible future reordering given an
insertion or deletion might be the only consideration
I could imagine.
