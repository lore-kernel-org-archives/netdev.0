From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2] nf_conntrack_proto_gre: switch to	register_pernet_gen_subsys()
Date: Tue, 28 Oct 2008 13:10:04 +0100
Message-ID: <4907011C.1040104@trash.net>
References: <20081025225104.GB18858@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	netfiter-devel@vger.kernel.org, containters@lists.osdl.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60866 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753056AbYJ1MKH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 08:10:07 -0400
In-Reply-To: <20081025225104.GB18858@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan wrote:
> register_pernet_gen_device() can't be used is nf_conntrack_pptp module is
> also used (compiled in or loaded).
> 
> Right now, proto_gre_net_exit() is called before nf_conntrack_pptp_net_exit().
> The former shutdowns and frees GRE piece of netns, however the latter
> absolutely needs it to flush keymap. Oops is inevitable.
> 
> Switch to shiny new register_pernet_gen_subsys() to get correct ordering in
> netns ops list.

Applied, thanks.
