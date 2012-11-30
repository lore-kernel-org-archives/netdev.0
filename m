From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH iproute2 v1] Add mdb command to bridge
Date: Fri, 30 Nov 2012 22:50:41 +0800
Message-ID: <1354287041.19865.2.camel@cr0>
References: <1354269514-1863-1-git-send-email-amwang@redhat.com>
	 <1354269514-1863-3-git-send-email-amwang@redhat.com>
	 <20121130105449.GE30697@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33657 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030469Ab2K3OvX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2012 09:51:23 -0500
In-Reply-To: <20121130105449.GE30697@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-11-30 at 10:54 +0000, Thomas Graf wrote:
> 
> You shouldn't need to duplicate the attribute ids and struct br_port_msg
> in iproute2. Just put these definitions in a uapi kernel header and
> include the header from iproute2.

Right, I was confused by include/linux/rtnetlink.h, thought iproute2 has
its own copy of these headers, but they should be exported from kernel.

Thanks!
