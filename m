From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] Enable tx timestamping on loopback and dummy
Date: Mon, 13 Mar 2017 12:15:04 -0700 (PDT)
Message-ID: <20170313.121504.1530815997705662155.davem@davemloft.net>
References: <20170312215231.GA10928@u480fcf44e5b8574c5490.ant.amazon.com>
        <20170313104006.GC1875@localhost.localdomain>
        <20170313111608.GA21070@u480fcf44e5b8574c5490.ant.amazon.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, netdev@vger.kernel.org
To: ezegomez@amazon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54164 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750917AbdCMTPG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 15:15:06 -0400
In-Reply-To: <20170313111608.GA21070@u480fcf44e5b8574c5490.ant.amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ezequiel Lara Gomez <ezegomez@amazon.com>
Date: Mon, 13 Mar 2017 11:16:10 +0000

> 
> From aef15784aecbf6cb08d181eca6186fe7d2261771 Mon Sep 17 00:00:00 2001
> From: Ezequiel Lara Gomez <ezegomez@amazon.com>
> Date: Sat, 11 Mar 2017 20:06:54 +0000
> Subject: [PATCH v4] Enable tx timestamping on loopback and dummy
> 
> This enables developing code that uses SOF_TIMESTAMPING_TX_SOFTWARE
> by using local addresses (without needing to send packets outside),
> as well as enabling unit and functional testing of TX timestamping code
> without needing hardware support or network access.
> 
> It also fulfills the expectation of software network devices supporting
> software-based timestamping.
> 
> Tested on qemu using txtimestamping.c from the kernel selftests, and
> ethtool -T.

Please read Documentation/SubmittingPatches, you are failing to provide
a proper signoff in your patch postings.
