From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Add ndo_gso_check
Date: Tue, 07 Oct 2014 13:05:04 -0400 (EDT)
Message-ID: <20141007.130504.1805673129740661479.davem@davemloft.net>
References: <CAADnVQLkWrjN=MgtU_8zBrGFW1eJd01hd6BM_m9iOq=ypHvSLQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, jesse@nicira.com, gerlitz.or@gmail.com,
	alexander.h.duyck@intel.com, john.r.fastabend@intel.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org, tgraf@suug.ch,
	pshelar@nicira.com, azhou@nicira.com
To: alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46478 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754216AbaJGRFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 13:05:08 -0400
In-Reply-To: <CAADnVQLkWrjN=MgtU_8zBrGFW1eJd01hd6BM_m9iOq=ypHvSLQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Tue, 7 Oct 2014 09:50:50 -0700

> CHECKSUM_COMPLETE is a burden on software.

I totally disagree, it's the most software friendly checksumming
offload mechanism possible.  I wish every card did it.

CHECKSUM_COMPLETE means that any sub-protocol or tunneling mechanism
can be trivially supported without any modifications to hardware, and
it therefore makes checksum offloading of new protocols require no
hardware changes whatsoever.
