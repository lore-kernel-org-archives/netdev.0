From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] test_bpf: fix the dummy skb after dissector changes
Date: Mon, 12 Sep 2016 15:31:51 +0200
Message-ID: <57D6AE47.2000608@iogearbox.net>
References: <1473681897-32260-1-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Hadar Hen Zion <hadarh@mellanox.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        Alexei Starovoitov <ast@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:51055 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756086AbcILNb6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 09:31:58 -0400
In-Reply-To: <1473681897-32260-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/12/2016 02:04 PM, Jakub Kicinski wrote:
> Commit d5709f7ab776 ("flow_dissector: For stripped vlan, get vlan
> info from skb->vlan_tci") made flow dissector look at vlan_proto
> when vlan is present.  Since test_bpf sets skb->vlan_tci to ~0
> (including VLAN_TAG_PRESENT) we have to populate skb->vlan_proto.
>
> Fixes false negative on test #24:
> test_bpf: #24 LD_PAYLOAD_OFF jited:0 175 ret 0 != 42 FAIL (1 times)
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Reviewed-by: Dinan Gunawardena <dinan.gunawardena@netronome.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
