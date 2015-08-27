From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: fix bpf_skb_set_tunnel_key() helper
Date: Wed, 26 Aug 2015 17:38:36 -0700 (PDT)
Message-ID: <20150826.173836.2165125021882656106.davem@davemloft.net>
References: <1440629858-1847-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38978 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751449AbbH0Aih (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 20:38:37 -0400
In-Reply-To: <1440629858-1847-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Wed, 26 Aug 2015 15:57:38 -0700

> Make sure to indicate to tunnel driver that key.tun_id is set,
> otherwise gre won't recognize the metadata.
> 
> Fixes: d3aa45ce6b94 ("bpf: add helpers to access tunnel metadata")
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
> With this fix both vxlan and gretap are working with tc+bpf.

Applied, thanks.
