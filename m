From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [AX.25 1/2] Introduce struct ax25_sock.
Date: Sat, 22 Jul 2006 08:13:43 -0400
Message-ID: <20060722121343.GA7579@linux-mips.org>
References: <20060721152946.GA16317@linux-mips.org> <20060722.013618.71088903.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:40645 "EHLO
	ftp.linux-mips.org") by vger.kernel.org with ESMTP id S1750796AbWGVPWo
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Jul 2006 11:22:44 -0400
Received: from localhost.localdomain ([127.0.0.1]:48580 "EHLO bacchus.dhis.org")
	by ftp.linux-mips.org with ESMTP id S8133572AbWGVPWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Jul 2006 16:22:42 +0100
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060722.013618.71088903.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 22, 2006 at 01:36:18AM -0700, David Miller wrote:

> > Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
> 
> This is very nice work Ralf, but I think it's 2.6.19 material.
> :-)

While this patch itself is more of a cleanup it's a prerequisite for
being able the use the sk_*_timer functions to fix the reference counts
in AX.25 timers ...

I have no problem to wait with deleting sk_protinfo :-)

  Ralf
