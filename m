From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] ip_tunnel, bpf: ip_tunnel_info_opts_{get,set}
 depends on CONFIG_INET
Date: Tue, 8 Mar 2016 14:59:16 -0800
Message-ID: <20160308225915.GA37181@ast-mbp.thefacebook.com>
References: <3ecfa7ed9f730147c925e010907cf920b8071a27.1457476284.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, tgraf@suug.ch, fengguang.wu@intel.com,
	netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33675 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750802AbcCHW7V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 17:59:21 -0500
Received: by mail-pa0-f52.google.com with SMTP id fl4so22669465pad.0
        for <netdev@vger.kernel.org>; Tue, 08 Mar 2016 14:59:21 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <3ecfa7ed9f730147c925e010907cf920b8071a27.1457476284.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 08, 2016 at 11:36:03PM +0100, Daniel Borkmann wrote:
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

Acked-by: Alexei Starovoitov <ast@kernel.org>
