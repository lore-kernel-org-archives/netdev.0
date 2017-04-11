From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bpf: reference may_access_skb() from __bpf_prog_run()
Date: Tue, 11 Apr 2017 10:55:58 -0400 (EDT)
Message-ID: <20170411.105558.942689285182526309.davem@davemloft.net>
References: <20170411101058.13526-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
        alexei.starovoitov@gmail.com, johannes.berg@intel.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60242 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753017AbdDKO4L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 10:56:11 -0400
In-Reply-To: <20170411101058.13526-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Tue, 11 Apr 2017 12:10:58 +0200

> From: Johannes Berg <johannes.berg@intel.com>
> 
> It took me quite some time to figure out how this was linked,
> so in order to save the next person the effort of finding it
> add a comment in __bpf_prog_run() that indicates what exactly
> determines that a program can access the ctx == skb.
> 
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

Applied, thanks Johannes.
