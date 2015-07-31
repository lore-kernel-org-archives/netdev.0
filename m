From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] bpf: add helpers to access tunnel metadata
Date: Fri, 31 Jul 2015 10:14:10 +0200
Message-ID: <20150731081410.GD4738@pox.localdomain>
References: <1438295817-27295-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:36708 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752665AbbGaION (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 04:14:13 -0400
Received: by wicgj17 with SMTP id gj17so6715470wic.1
        for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 01:14:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1438295817-27295-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/30/15 at 03:36pm, Alexei Starovoitov wrote:
> +	to->tunnel_id = be64_to_cpu(info->key.tun_id);
> +	to->remote_ipv4 = be32_to_cpu(info->key.ipv4_src);

BTW: I have a patch ready to avoid this as you suggested which I'll
post as soon as GRE and Geneve are done as well. It would require a
lot of special handling until all encaps have been converted.
