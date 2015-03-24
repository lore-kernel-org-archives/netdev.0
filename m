From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next v3] filter: introduce SKF_AD_VLAN_TPID BPF extension
Date: Tue, 24 Mar 2015 08:17:37 -0700
Message-ID: <55118011.60002@plumgrid.com>
References: <1427204921-14535-1-git-send-email-msekleta@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Jiri Pirko <jpirko@redhat.com>
To: Michal Sekletar <msekleta@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:37049 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752139AbbCXPRk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 11:17:40 -0400
Received: by igcxg11 with SMTP id xg11so100450igc.0
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 08:17:39 -0700 (PDT)
In-Reply-To: <1427204921-14535-1-git-send-email-msekleta@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/24/15 6:48 AM, Michal Sekletar wrote:
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

Acked-by: Alexei Starovoitov <ast@plumgrid.com>
