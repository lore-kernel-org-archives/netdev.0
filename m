From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH 1/2] ax25: Stop using sock->sk_protinfo.
Date: Fri, 26 Jun 2015 23:43:05 +0200
Message-ID: <20150626214305.GB13920@linux-mips.org>
References: <20150625.061907.1258416005349767495.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kda@linux-powerpc.org, netdev@vger.kernel.org, edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([148.251.95.138]:59933 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752175AbbFZVnO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 17:43:14 -0400
Received: from localhost.localdomain ([127.0.0.1]:54196 "EHLO linux-mips.org"
        rhost-flags-OK-OK-OK-FAIL) by eddie.linux-mips.org with ESMTP
        id S27009422AbbFZVnM5D2Y8 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 26 Jun 2015 23:43:12 +0200
Content-Disposition: inline
In-Reply-To: <20150625.061907.1258416005349767495.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 25, 2015 at 06:19:07AM -0700, David Miller wrote:

> Just make a ax25_sock structure that provides the ax25_cb pointer.

Nice minimal solution, thanks!

I have the big solution my queue which combines struct sock with ax25_cb
into struct ax25_sock but that's more complex because currently there is
the possibility for an ax25_cb to be created by an incoming connection
request even without a socket.

  Ralf
