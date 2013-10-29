From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: sched: cls_bpf: add BPF-based
 classifier
Date: Tue, 29 Oct 2013 17:34:09 -0400 (EDT)
Message-ID: <20131029.173409.627047475551100692.davem@davemloft.net>
References: <cover.1382974535.git.dborkman@redhat.com>
	<8b7eb31a8976ea086ff904e42514e4ab3d937712.1382974535.git.dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, tgraf@suug.ch
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48910 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752609Ab3J2VeL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 17:34:11 -0400
In-Reply-To: <8b7eb31a8976ea086ff904e42514e4ab3d937712.1382974535.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Mon, 28 Oct 2013 16:43:02 +0100

> This work contains a lightweight BPF-based traffic classifier that can
> serve as a flexible alternative to ematch-based tree classification, i.e.
> now that BPF filter engine can also be JITed in the kernel. Naturally, tc
> actions and policies are supported as well with cls_bpf. Multiple BPF
> programs/filter can be attached for a class, or they can just as well be
> written within a single BPF program, that's really up to the user how he
> wishes to run/optimize the code, e.g. also for inversion of verdicts etc.
> The notion of a BPF program's return/exit codes is being kept as follows:

This looks great, although a lot of things this supports could be done
using u32 filters, but this is more flexible.

Applied, thanks.
