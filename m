From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [patch] netfilter: information leaks building packet message
Date: Thu, 8 Aug 2013 14:02:54 +0200
Message-ID: <20130808120254.GA6822@localhost>
References: <20130801093656.GA12455@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60913 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757786Ab3HHMDE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Aug 2013 08:03:04 -0400
Content-Disposition: inline
In-Reply-To: <20130801093656.GA12455@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 01, 2013 at 12:36:57PM +0300, Dan Carpenter wrote:
> These structs have a "_pad" member.  Also the "phw" structs have an 8
> byte "hw_addr[]" array but sometimes only the first 6 bytes are
> initialized.

Applied, thanks.
