From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] bpf: permit bpf program narrower loads for ctx
 fields
Date: Wed, 14 Jun 2017 14:56:43 -0400 (EDT)
Message-ID: <20170614.145643.2012517060599322594.davem@davemloft.net>
References: <20170613225214.2854085-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, daniel@iogearbox.net, netdev@vger.kernel.org,
        kernel-team@fb.com
To: yhs@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53380 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750768AbdFNS4p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 14:56:45 -0400
In-Reply-To: <20170613225214.2854085-1-yhs@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yonghong Song <yhs@fb.com>
Date: Tue, 13 Jun 2017 15:52:12 -0700

> Today, if users try to access a ctx field through a narrower load, e.g.,
> __be16 prot = __sk_buff->protocol, verifier will fail.
> This set contains the verifier change to permit such loads for
> certain ctx fields as well as the new test cases in selftests/bpf.

Series applied to net-next, thanks.
