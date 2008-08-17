From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] netns: fix NULL-dereference in dev_net()
Date: Sun, 17 Aug 2008 15:34:19 -0700 (PDT)
Message-ID: <20080817.153419.245583133.davem@davemloft.net>
References: <48A4871D.1030708@hp.com>
	<48A746E1.90703@fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, containers@lists.osdl.org,
	netdev@vger.kernel.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44749
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751758AbYHQWeT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2008 18:34:19 -0400
In-Reply-To: <48A746E1.90703@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Sat, 16 Aug 2008 23:30:09 +0200

> Brian Haley wrote:
> > Change dev_net() to handle a NULL argument - return &init_net instead.
> > 
> > -Brian
> > 
> > Signed-off-by: Brian Haley <brian.haley@hp.com>
> 
> Did you fall into the case where the argument was NULL ?

Brian retracted this patch and we checked in a different fix.
