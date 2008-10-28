From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/2] netns: add	register_pernet_gen_subsys/unregister_pernet_gen_subsys
Date: Tue, 28 Oct 2008 13:09:15 +0100
Message-ID: <490700EB.6070206@trash.net>
References: <20081025224323.GA18858@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	netfiter-devel@vger.kernel.org, containters@lists.osdl.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60823 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752627AbYJ1MJS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 08:09:18 -0400
In-Reply-To: <20081025224323.GA18858@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan wrote:
> netns ops which are registered with register_pernet_gen_device() are
> shutdown strictly before those which are registered with
> register_pernet_subsys(). Sometimes this leads to opposite (read: buggy)
> shutdown ordering between two modules.
> 
> Add register_pernet_gen_subsys()/unregister_pernet_gen_subsys() for modules
> which aren't elite enough for entry in struct net, and which can't use
> register_pernet_gen_device(). PPTP conntracking module is such one.

Applied, thanks.
