From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mips: bpf: Fix broken BPF_MOD
Date: Mon, 08 Dec 2014 20:23:08 -0500 (EST)
Message-ID: <20141208.202308.566845942442626642.davem@davemloft.net>
References: <1417427822-12729-1-git-send-email-kda@linux-powerpc.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, markos.chandras@imgtec.com
To: kda@linux-powerpc.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59015 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103AbaLIBXK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 20:23:10 -0500
In-Reply-To: <1417427822-12729-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Kirjanov <kda@linux-powerpc.org>
Date: Mon,  1 Dec 2014 12:57:02 +0300

> Remove optimize_div() from BPF_MOD | BPF_K case
> since we don't know the dividend and fix the
> emit_mod() by reading the mod operation result from HI register
> 
> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>

Applied and queue up for -stable, thanks.
