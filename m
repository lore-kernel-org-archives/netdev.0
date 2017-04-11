From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 1/2] bpf: remove struct bpf_prog_type_list
Date: Tue, 11 Apr 2017 14:39:09 -0400 (EDT)
Message-ID: <20170411.143909.674961610138152128.davem@davemloft.net>
References: <20170411133458.26816-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, johannes.berg@intel.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34828 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753172AbdDKSjM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 14:39:12 -0400
In-Reply-To: <20170411133458.26816-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Tue, 11 Apr 2017 15:34:57 +0200

> From: Johannes Berg <johannes.berg@intel.com>
> 
> There's no need to have struct bpf_prog_type_list since
> it just contains a list_head, the type, and the ops
> pointer. Since the types are densely packed and not
> actually dynamically registered, it's much easier and
> smaller to have an array of type->ops pointer. Also
> initialize this array statically to remove code needed
> to initialize it.
> 
> In order to save duplicating the list, move it to a new
> header file and include it in the places needing it.
> 
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

Applied.
