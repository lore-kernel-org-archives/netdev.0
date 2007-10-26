From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] remove __net_initdata attribute
Date: Fri, 26 Oct 2007 04:34:34 -0700 (PDT)
Message-ID: <20071026.043434.205673741.davem@davemloft.net>
References: <20071026095652.GA8788@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: devel@openvz.org, netdev@vger.kernel.org,
	containers@lists.osdl.org, benjamin.thery@bull.net, clg@fr.ibm.com
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42009
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750973AbXJZLed (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2007 07:34:33 -0400
In-Reply-To: <20071026095652.GA8788@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Denis V. Lunev" <den@openvz.org>
Date: Fri, 26 Oct 2007 13:56:52 +0400

> The discussion with Eric W. Biederman reveals that the concept for
> __net_initdata is bogus. The ->exit method of pernet_operations
> should be called during module exit.
> 
> So, discard this attribute.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Exactly what I just asked for :-)

Applied, thanks!
