From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] netns: add
 register_pernet_gen_subsys/unregister_pernet_gen_subsys
Date: Sun, 26 Oct 2008 21:56:25 -0700 (PDT)
Message-ID: <20081026.215625.193693733.davem@davemloft.net>
References: <20081025224323.GA18858@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	netfiter-devel@vger.kernel.org, containters@lists.osdl.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54255
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751321AbYJ0E4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 00:56:48 -0400
In-Reply-To: <20081025224323.GA18858@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Sun, 26 Oct 2008 02:43:24 +0400

> netns ops which are registered with register_pernet_gen_device() are
> shutdown strictly before those which are registered with
> register_pernet_subsys(). Sometimes this leads to opposite (read: buggy)
> shutdown ordering between two modules.
> 
> Add register_pernet_gen_subsys()/unregister_pernet_gen_subsys() for modules
> which aren't elite enough for entry in struct net, and which can't use
> register_pernet_gen_device(). PPTP conntracking module is such one.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

I'll let Patrick take this one with your PPTP netns changes.
