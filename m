From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ip_tunnel, bpf: ip_tunnel_info_opts_{get,set}
 depends on CONFIG_INET
Date: Tue, 08 Mar 2016 23:21:07 -0500 (EST)
Message-ID: <20160308.232107.2293307827554042545.davem@davemloft.net>
References: <3ecfa7ed9f730147c925e010907cf920b8071a27.1457476284.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	fengguang.wu@intel.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49707 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751654AbcCIEVP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 23:21:15 -0500
In-Reply-To: <3ecfa7ed9f730147c925e010907cf920b8071a27.1457476284.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Tue,  8 Mar 2016 23:36:03 +0100

> Helpers like ip_tunnel_info_opts_{get,set}() are only available if
> CONFIG_INET is set, thus add an empty definition into the header for
> the !CONFIG_INET case, where already other empty inline helpers are
> defined.
> 
> This avoids ifdef kludge inside filter.c, but also vxlan and geneve
> themself where this facility can only be used with, depend on INET
> being set. For the !INET case TUNNEL_OPTIONS_PRESENT would never be
> set in flags.
> 
> Fixes: 14ca0751c96f ("bpf: support for access to tunnel options")
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks Daniel.
