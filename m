From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [RFCv4 PATCH 1/2] net: Introduce recvmmsg socket syscall
Date: Fri, 9 Oct 2009 16:35:20 -0300
Message-ID: <20091009193520.GD12982@ghostprotocols.net>
References: <20090916170738.GC7699@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Caitlin Bestler <caitlin.bestler@gmail.com>,
	Chris Van Hoof <vanhoof@redhat.com>,
	Clark Williams <williams@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Nir Tzachar <nir.tzachar@gmail.com>,
	Nivedita Singhvi <niv@us.ibm.com>,
	Paul Moore <paul.moore@hp.com>,
	=?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>,
	Steven Whitehouse <steve@chygwyn.com>,
	Linux Networking Development Mailing List
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60477 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934040AbZJITgZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Oct 2009 15:36:25 -0400
Content-Disposition: inline
In-Reply-To: <20090916170738.GC7699@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Wed, Sep 16, 2009 at 02:07:38PM -0300, Arnaldo Carvalho de Melo escreveu:
> Meaning receive multiple messages, reducing the number of syscalls and
> net stack entry/exit operations.
>
> Next patches will introduce mechanisms where protocols that want to
> optimize this operation will provide an unlocked_recvmsg operation.

Hi Dave,

	The second patch in this series has issues, I still have to
investigate it properly, study removing the skb_queue_head lock like TCP
does, but the first patch seems to be OK and already providing good
results at least as reported by Nir, if there aren't any other concerns
about the API, can we get it into net-next-2.6?

Best Regards,

- Arnaldo
