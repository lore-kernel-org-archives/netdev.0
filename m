From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] test_bpf: fix the dummy skb after dissector changes
Date: Mon, 12 Sep 2016 09:18:23 -0700
Message-ID: <20160912161822.GA12817@ast-mbp.thefacebook.com>
References: <1473681897-32260-1-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        Hadar Hen Zion <hadarh@mellanox.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33371 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751120AbcILQS3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 12:18:29 -0400
Received: by mail-pf0-f194.google.com with SMTP id 128so8303921pfb.0
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 09:18:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1473681897-32260-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 12, 2016 at 01:04:57PM +0100, Jakub Kicinski wrote:
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

Thanks! This is for net-next. Pls mention that in the subj next time.
Acked-by: Alexei Starovoitov <ast@kernel.org>
