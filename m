From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: fix error path in sctp_proc_init
Date: Tue, 17 Jun 2008 14:41:38 -0700 (PDT)
Message-ID: <20080617.144138.71736435.davem@davemloft.net>
References: <4857AE19.9050708@openvz.org>
	<4857C025.8010701@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48231
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756432AbYFQVli (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 17:41:38 -0400
In-Reply-To: <4857C025.8010701@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Tue, 17 Jun 2008 09:46:13 -0400

> Pavel Emelyanov wrote:
> > After the sctp_remaddr_proc_init failed, the proper rollback is
> > not the sctp_remaddr_proc_exit, but the sctp_assocs_proc_exit.
> > 
> > Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> Ack for net-next-2.6.
> 
> Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>

I added this bug during the net-2.6 --> net-next-2.6 merge, sorry :-)

I'll apply this, thanks everyone!
