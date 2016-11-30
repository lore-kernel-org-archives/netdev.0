From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 1/1] samples: bpf: Refactor test_cgrp2_attach -- use
 getopt, and add mode
Date: Wed, 30 Nov 2016 10:29:59 -0500 (EST)
Message-ID: <20161130.102959.1171017574583467201.davem@davemloft.net>
References: <20161128225240.GA8761@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@zonque.org, ast@fb.com
To: sargun@sargun.me
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33482 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756551AbcK3PaA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 10:30:00 -0500
In-Reply-To: <20161128225240.GA8761@ircssh.c.rugged-nimbus-611.internal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sargun Dhillon <sargun@sargun.me>
Date: Mon, 28 Nov 2016 14:52:42 -0800

> This patch modifies test_cgrp2_attach to use getopt so we can use standard
> command line parsing.
> 
> It also adds an option to run the program in detach only mode. This does
> not attach a new filter at the cgroup, but only runs the detach command.
> 
> Lastly, it changes the attach code to not detach and then attach. It relies
> on the 'hotswap' behaviour of CGroup BPF programs to be able to change
> in-place. If detach-then-attach behaviour needs to be tested, the example
> can be run in detach only mode prior to attachment.
> 
> Signed-off-by: Sargun Dhillon <sargun@sargun.me>

Applied, thanks.
