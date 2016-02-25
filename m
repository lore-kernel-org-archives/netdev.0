From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: fix csum setting for bpf_set_tunnel_key
Date: Thu, 25 Feb 2016 11:36:07 -0500 (EST)
Message-ID: <20160225.113607.876401940894301137.davem@davemloft.net>
References: <cb92edae7e6cb23d349d714736362535e56a1c75.1456188678.git.daniel@iogearbox.net>
	<20160224.162400.1248598061435588351.davem@davemloft.net>
	<56CEDB5B.7060805@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch, jesse@kernel.org,
	netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42618 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757854AbcBYQgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 11:36:09 -0500
In-Reply-To: <56CEDB5B.7060805@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 25 Feb 2016 11:45:47 +0100

> On 02/24/2016 10:24 PM, David Miller wrote:
> [...]
>> Applied to 'net', thanks Daniel.
> 
> Thanks!
> 
> Btw, in case net gets merged into net-next, there will be a minor
> merge conflict due to stackid flags present in net-next. This can
> be easily resolved by keeping both chunks.
> 
> For example, result after merge in include/uapi/linux/bpf.h then
> looks like:
 ...

Thanks for the heads up.
