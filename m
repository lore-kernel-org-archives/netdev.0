From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/9] Collect common sysctl variables together
Date: Mon, 15 Oct 2007 02:33:57 -0700 (PDT)
Message-ID: <20071015.023357.84956849.davem@davemloft.net>
References: <470F6EAE.60308@openvz.org>
	<470F722D.90207@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42253
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757055AbXJOJdw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 05:33:52 -0400
In-Reply-To: <470F722D.90207@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 12 Oct 2007 17:10:05 +0400

> Some sysctl variables are used to tune the frag queues
> management and it will be useful to work with them in
> a common way in the future, so move them into one
> structure, moreover they are the same for all the frag
> management codes.
> 
> I don't place them in the existing inet_frags object,
> introduced in the previous patch for two reasons:
> 
>  1. to keep them in the __read_mostly section;
>  2. not to export the whole inet_frags objects outside.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
