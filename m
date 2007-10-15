From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/9] Consolidate xxx_the secret_rebuild
Date: Mon, 15 Oct 2007 02:38:40 -0700 (PDT)
Message-ID: <20071015.023840.11367878.davem@davemloft.net>
References: <470F6EAE.60308@openvz.org>
	<470F73A9.5070102@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53563
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757750AbXJOJif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 05:38:35 -0400
In-Reply-To: <470F73A9.5070102@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 12 Oct 2007 17:16:25 +0400

> This code works with the generic data types as well, so
> move this into inet_fragment.c
> 
> This move makes it possible to hide the secret_timer
> management and the secret_rebuild routine completely in
> the inet_fragment.c
> 
> Introduce the ->hashfn() callback in inet_frags() to get
> the hashfun for a given inet_frag_queue() object.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
