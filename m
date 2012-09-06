From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Increased multicast packet drops in 3.4
Date: Thu, 06 Sep 2012 08:26:19 +0200
Message-ID: <1346912779.13121.178.camel@edumazet-glaptop>
References: <20120906001108.GA6035@BohrerMBP.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Shawn Bohrer <sbohrer@rgmadvisors.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:40779 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751388Ab2IFG0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 02:26:24 -0400
Received: by bkwj10 with SMTP id j10so607837bkw.19
        for <netdev@vger.kernel.org>; Wed, 05 Sep 2012 23:26:22 -0700 (PDT)
In-Reply-To: <20120906001108.GA6035@BohrerMBP.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-05 at 19:11 -0500, Shawn Bohrer wrote:
> One thing I find interesting is that some of the time 2
> or 3 of the 8 processes will report that they missed the exact same
> 50+ packets.  Since the other processes receive the packets I know
> that they are making it to the machine and past the driver.

Could it be that these processes missing 50+ packets provide a non
accessible area of memory and these recvmsg() calls return EFAULT ?

Are you using special memory areas, using mprotect(), or huge pages for
example ?
