From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/7] Consolidate xxx_frag_create()
Date: Wed, 17 Oct 2007 19:46:56 -0700 (PDT)
Message-ID: <20071017.194656.131105362.davem@davemloft.net>
References: <4714C0AF.1000209@openvz.org>
	<4714C3EA.4080109@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35831
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756760AbXJRCq5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 22:46:57 -0400
In-Reply-To: <4714C3EA.4080109@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 16 Oct 2007 18:00:10 +0400

> This one uses the xxx_frag_intern() and xxx_frag_alloc()
> routines, which are already consolidated, so remove them
> from protocol code (as promised).
> 
> The ->constructor callback is used to init the rest of
> the frag queue and it is the same for netfilter and ipv6.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
