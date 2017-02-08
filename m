From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net] bpf: add bpf_sk_netns_id() helper
Date: Wed, 08 Feb 2017 13:16:18 -0500 (EST)
Message-ID: <20170208.131618.1840963382948020607.davem@davemloft.net>
References: <1486432968-3255218-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, dsa@cumulusnetworks.com, tj@kernel.org,
        luto@amacapital.net, ebiederm@xmission.com, netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55786 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750941AbdBHSRL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 13:17:11 -0500
In-Reply-To: <1486432968-3255218-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Mon, 6 Feb 2017 18:02:48 -0800

> Eric, I'v added proc_get_ns_devid_inum() to nsfs.c
> right next to __ns_get_path(), so when it is time in the future
> to make nsfs more namespace aware, it will be easy to adjust
> both new_inode_pseudo(mnt->mnt_sb) line and proc_get_ns_devid_inum()
> I thought about using ns->stashed, but it's obviously transient
> inode and not usable. If later we decide to store dev_t into ns_common
> it will be fine as well. We'll just change proc_get_ns_devid_inum()
> without affecting user space.

Eric?
