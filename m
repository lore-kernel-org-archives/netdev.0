From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/7] Consolidate xxx_find() in fragment management
Date: Wed, 17 Oct 2007 19:47:29 -0700 (PDT)
Message-ID: <20071017.194729.35660833.davem@davemloft.net>
References: <4714C0AF.1000209@openvz.org>
	<4714C4B9.5010606@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35834
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759598AbXJRCra (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 22:47:30 -0400
In-Reply-To: <4714C4B9.5010606@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 16 Oct 2007 18:03:37 +0400

> Here we need another callback ->match to check whether the
> entry found in hash matches the key passed. The key used 
> is the same as the creation argument for inet_frag_create.
> 
> Yet again, this ->match is the same for netfilter and ipv6.
> Running a frew steps forward - this callback will later
> replace the ->equal one.
> 
> Since the inet_frag_find() uses the already consolidated
> inet_frag_create() remove the xxx_frag_create from protocol
> codes.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
