From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: filter: initialize A and X registers
Date: Wed, 23 Apr 2014 15:35:29 -0400 (EDT)
Message-ID: <20140423.153529.355887454605859828.davem@davemloft.net>
References: <1398223137-5463-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51234 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754008AbaDWTfa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 15:35:30 -0400
In-Reply-To: <1398223137-5463-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Tue, 22 Apr 2014 20:18:57 -0700

> exisiting BPF verifier allows uninitialized access to registers,
> 'ret A' is considered to be a valid filter.
> So initialize A and X to zero to prevent leaking kernel memory
> In the future BPF verifier will be rejecting such filters
> 
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied, thanks.
