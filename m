From: David Miller <davem@davemloft.net>
Subject: Re: [AX.25 1/2] Introduce struct ax25_sock.
Date: Sat, 22 Jul 2006 01:36:18 -0700 (PDT)
Message-ID: <20060722.013618.71088903.davem@davemloft.net>
References: <20060721152946.GA16317@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:42411
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751223AbWGVIgV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Jul 2006 04:36:21 -0400
To: ralf@linux-mips.org
In-Reply-To: <20060721152946.GA16317@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Fri, 21 Jul 2006 11:29:46 -0400

> Upto now AX.25 was using two separate structures for it's sockets.  One,
> ax25_cb described the entire actual AX.25 connection.  The other was
> the standard struct sock.
> 
> This patch combines both into struct ax25_sock which is more in line with
> current practice.  An AX.25 speciality was that a ax25_cb could exist
> without a struct sock referencing it.  Keep that alive for now by keeping
> the old struct sock *sk member of ax25_cb in struct ax25_sock.  This now
> just has become a struct-internal pointer.
> 
> Aside of wanrouter AX.25 has also been the last member of struct
> sock.sk_protinfo.  With net/wanrouter being considered hopeless code and
> an application-level solution being prefered these days this means we now
> can delete sk_protinfo.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

This is very nice work Ralf, but I think it's 2.6.19 material.
:-)
