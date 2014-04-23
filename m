From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] filter: added BPF random opcode
Date: Tue, 22 Apr 2014 21:29:26 -0400 (EDT)
Message-ID: <20140422.212926.1630952101567041636.davem@davemloft.net>
References: <1397585816-1267-1-git-send-email-chema@google.com>
	<1398097284-20528-1-git-send-email-chema@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, dborkman@redhat.com, ast@plumgrid.com,
	netdev@vger.kernel.org
To: chema@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44909 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753097AbaDWB31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 21:29:27 -0400
In-Reply-To: <1398097284-20528-1-git-send-email-chema@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chema Gonzalez <chema@google.com>
Date: Mon, 21 Apr 2014 09:21:24 -0700

> Added a new ancillary load (bpf call in eBPF parlance) that produces
> a 32-bit random number. We are implementing it as an ancillary load
> (instead of an ISA opcode) because (a) it is simpler, (b) allows easy
> JITing, and (c) seems more in line with generic ISAs that do not have
> "get a random number" as a instruction, but as an OS call.
> 
> The main use for this ancillary load is to perform random packet sampling.
> 
> Signed-off-by: Chema Gonzalez <chema@google.com>

Applied.
