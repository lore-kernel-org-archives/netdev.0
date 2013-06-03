From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: panics in tcp_ack
Date: Sun, 02 Jun 2013 17:26:07 -0700
Message-ID: <1370219167.24311.108.camel@edumazet-glaptop>
References: <51ABE067.2050507@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rob Herring <robherring2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:48680 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755254Ab3FCA0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jun 2013 20:26:08 -0400
Received: by mail-pb0-f43.google.com with SMTP id ma3so4887052pbc.30
        for <netdev@vger.kernel.org>; Sun, 02 Jun 2013 17:26:08 -0700 (PDT)
In-Reply-To: <51ABE067.2050507@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-06-02 at 19:16 -0500, Rob Herring wrote:
> Sorry, this time with proper line wrapping...
> 
> I'm debugging a kernel panic in the networking stack that happens with a
> cluster (20-40 nodes) of Calxeda highbank (ARM Cortex A9) nodes and
> typically only after 10-24 hours. The node are transferring files
> between nodes over TCP with 20 clients and servers per node. The kernel
> is based on ubuntu 3.5 kernel which is based on 3.5.7.11. So far testing
> has shown that 3.8.11 based (ubuntu raring) kernel is fixed. Attempts to
> bisect have not yielded results as it seems multiple problems mask the
> issue. Perhaps there is some new feature which has indirectly fixed the
> problem in 3.8.

Oh well, you said it was fixed in 3.8, sorry for my prior mail.
