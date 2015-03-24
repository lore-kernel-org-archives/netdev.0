From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH net-next v3] filter: introduce SKF_AD_VLAN_TPID BPF
 extension
Date: Tue, 24 Mar 2015 16:44:09 +0100
Message-ID: <20150324154409.GD2050@nanopsycho.orion>
References: <1427204921-14535-1-git-send-email-msekleta@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>
To: Michal Sekletar <msekleta@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47969 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752909AbbCXPob (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Mar 2015 11:44:31 -0400
Content-Disposition: inline
In-Reply-To: <1427204921-14535-1-git-send-email-msekleta@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Mar 24, 2015 at 02:48:41PM CET, msekleta@redhat.com wrote:
>If vlan offloading takes place then vlan header is removed from frame
>and its contents, both vlan_tci and vlan_proto, is available to user
>space via TPACKET interface. However, only vlan_tci can be used in BPF
>filters.
>
>This commit introduces a new BPF extension. It makes possible to load
>the value of vlan_proto (vlan TPID) to register A. Support for classic
>BPF and eBPF is being added, analogous to skb->protocol.
>
>Cc: Daniel Borkmann <daniel@iogearbox.net>
>Cc: Alexei Starovoitov <ast@plumgrid.com>
>Cc: Jiri Pirko <jpirko@redhat.com>
>
>Signed-off-by: Michal Sekletar <msekleta@redhat.com>

Reviewed-by: Jiri Pirko <jiri@resnulli.us>
