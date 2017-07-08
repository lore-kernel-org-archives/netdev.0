From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 00/12] Implement XDP bpf_redirect vairants
Date: Sat, 08 Jul 2017 10:46:18 +0100 (WEST)
Message-ID: <20170708.104618.2149883426031901592.davem@davemloft.net>
References: <20170707172115.9984.53461.stgit@john-Precision-Tower-5810>
        <595FC974.9030807@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brouer@redhat.com, andy@greyhouse.net,
        daniel@iogearbox.net, ast@fb.com, alexander.duyck@gmail.com,
        bjorn.topel@intel.com, jakub.kicinski@netronome.com,
        ecree@solarflare.com, sgoutham@cavium.com, Yuval.Mintz@cavium.com,
        saeedm@mellanox.com
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40796 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752636AbdGHJqm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Jul 2017 05:46:42 -0400
In-Reply-To: <595FC974.9030807@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Fri, 07 Jul 2017 10:48:36 -0700

> On 07/07/2017 10:34 AM, John Fastabend wrote:
>> This series adds two new XDP helper routines bpf_redirect() and
>> bpf_redirect_map(). The first variant bpf_redirect() is meant
>> to be used the same way it is currently being used by the cls_bpf
>> classifier. An xdp packet will be redirected immediately when this
>> is called.
> 
> Also other than the typo in the title there ;) I'm going to CC
> the driver maintainers working on XDP (makes for a long CC list but)
> because we would want to try and get support in as many as possible in
> the next merge window.
> 
> For this rev I just implemented on ixgbe because I wrote the
> original XDP support there. I'll volunteer to do virtio as well.

I went over this series a few times and it looks great to me.
You didn't even give me some coding style issues to pick on :-)
