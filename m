From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] filter: introduce SKF_AD_VLAN_TPID BPF
 extension
Date: Tue, 24 Mar 2015 15:26:41 -0400 (EDT)
Message-ID: <20150324.152641.1956497494389302908.davem@davemloft.net>
References: <1427204921-14535-1-git-send-email-msekleta@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, ast@plumgrid.com,
	jpirko@redhat.com
To: msekleta@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38783 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753107AbbCXT0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 15:26:43 -0400
In-Reply-To: <1427204921-14535-1-git-send-email-msekleta@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Sekletar <msekleta@redhat.com>
Date: Tue, 24 Mar 2015 14:48:41 +0100

> If vlan offloading takes place then vlan header is removed from frame
> and its contents, both vlan_tci and vlan_proto, is available to user
> space via TPACKET interface. However, only vlan_tci can be used in BPF
> filters.
> 
> This commit introduces a new BPF extension. It makes possible to load
> the value of vlan_proto (vlan TPID) to register A. Support for classic
> BPF and eBPF is being added, analogous to skb->protocol.
> 
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> Cc: Jiri Pirko <jpirko@redhat.com>
> 
> Signed-off-by: Michal Sekletar <msekleta@redhat.com>

Applied.
