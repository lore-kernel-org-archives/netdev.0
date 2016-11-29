From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next 1/1] samples: bpf: Refactor test_cgrp2_attach -- use
 getopt, and add mode
Date: Mon, 28 Nov 2016 19:50:22 -0800
Message-ID: <20161129035020.GA15161@ast-mbp.thefacebook.com>
References: <20161128225240.GA8761@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@zonque.org, ast@fb.com
To: Sargun Dhillon <sargun@sargun.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35316 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754870AbcK2Du2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 22:50:28 -0500
Received: by mail-pg0-f65.google.com with SMTP id p66so14972706pga.2
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 19:50:27 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161128225240.GA8761@ircssh.c.rugged-nimbus-611.internal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 28, 2016 at 02:52:42PM -0800, Sargun Dhillon wrote:
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

looks fine to me.
I'd really prefer this example to become an automated test eventually.

Acked-by: Alexei Starovoitov <ast@kernel.org>
