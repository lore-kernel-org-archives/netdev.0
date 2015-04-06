From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tc: bpf: add checksum helpers
Date: Mon, 06 Apr 2015 16:42:57 -0400 (EDT)
Message-ID: <20150406.164257.2290989583284445419.davem@davemloft.net>
References: <1427933533-14394-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, jiri@resnulli.us, jhs@mojatatu.com,
	linux-api@vger.kernel.org, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48311 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753062AbbDFUm7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2015 16:42:59 -0400
In-Reply-To: <1427933533-14394-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Wed,  1 Apr 2015 17:12:13 -0700

> Commit 608cd71a9c7c ("tc: bpf: generalize pedit action") has added the
> possibility to mangle packet data to BPF programs in the tc pipeline.
> This patch adds two helpers bpf_l3_csum_replace() and bpf_l4_csum_replace()
> for fixing up the protocol checksums after the packet mangling.
> 
> It also adds 'flags' argument to bpf_skb_store_bytes() helper to avoid
> unnecessary checksum recomputations when BPF programs adjusting l3/l4
> checksums and documents all three helpers in uapi header.
> 
> Moreover, a sample program is added to show how BPF programs can make use
> of the mangle and csum helpers.
> 
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied, thanks.
