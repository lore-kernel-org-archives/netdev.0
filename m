From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v3] filter: introduce SKF_AD_VLAN_TPID BPF extension
Date: Tue, 24 Mar 2015 14:55:17 +0100
Message-ID: <55116CC5.4000706@iogearbox.net>
References: <1427204921-14535-1-git-send-email-msekleta@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	Jiri Pirko <jpirko@redhat.com>
To: Michal Sekletar <msekleta@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33461 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752441AbbCXNzW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 09:55:22 -0400
In-Reply-To: <1427204921-14535-1-git-send-email-msekleta@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/24/2015 02:48 PM, Michal Sekletar wrote:
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

Looks good to me, thanks!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
