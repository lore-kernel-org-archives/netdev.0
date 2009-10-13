From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: Introduce recvmmsg socket syscall
Date: Mon, 12 Oct 2009 23:40:46 -0700 (PDT)
Message-ID: <20091012.234046.234165425.davem@davemloft.net>
References: <y>
	<1255364440-23271-1-git-send-email-acme@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, caitlin.bestler@gmail.com,
	vanhoof@redhat.com, williams@redhat.com, nhorman@tuxdriver.com,
	nir.tzachar@gmail.com, niv@us.ibm.com, paul.moore@hp.com,
	remi.denis-courmont@nokia.com, steve@chygwyn.com
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38634
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758922AbZJMGku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 02:40:50 -0400
In-Reply-To: <1255364440-23271-1-git-send-email-acme@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Mon, 12 Oct 2009 13:20:40 -0300

> Meaning receive multiple messages, reducing the number of syscalls and
> net stack entry/exit operations.
> 
> Next patches will introduce mechanisms where protocols that want to
> optimize this operation will provide an unlocked_recvmsg operation.
> 
> This takes into account comments made by:
 ...
> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

You missed the syscall entry addition for arch/sparc/kernel/systbls_32.S
but I fixed that up while applying this to net-next-2.6

Thanks.
