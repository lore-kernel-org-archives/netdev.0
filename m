From: Jan Stancek <jstancek@redhat.com>
Subject: Re: [PATCH net] cxgb3: fix out of bounds read
Date: Mon, 2 May 2016 06:30:42 -0400 (EDT)
Message-ID: <1716157952.2031963.1462185042371.JavaMail.zimbra@redhat.com>
References: <1461920810-15228-1-git-send-email-mschmidt@redhat.com> <20160501.210000.607575204509045130.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, santosh@chelsio.com
To: David Miller <davem@davemloft.net>, mschmidt@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4-phx2.redhat.com ([209.132.183.25]:56512 "EHLO
	mx4-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753115AbcEBKap (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 06:30:45 -0400
In-Reply-To: <20160501.210000.607575204509045130.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- Original Message -----
> From: "David Miller" <davem@davemloft.net>
> To: mschmidt@redhat.com
> Cc: netdev@vger.kernel.org, santosh@chelsio.com, jstancek@redhat.com
> Sent: Monday, 2 May, 2016 3:00:00 AM
> Subject: Re: [PATCH net] cxgb3: fix out of bounds read
> 
> From: Michal Schmidt <mschmidt@redhat.com>
> Date: Fri, 29 Apr 2016 11:06:50 +0200
> 
> > An out of bounds read of 2 bytes was discovered in cxgb3 with KASAN.
> > 
> > t3_config_rss() expects both arrays it gets as parameters to have
> > terminators. setup_rss(), the caller, forgets to add a terminator to
> > one of the arrays. Thankfully the iteration in t3_config_rss() stops
> > anyway, but in the last iteration the check for the terminator
> > is an out of bounds read.
> > 
> > Add the missing terminator to rspq_map[].
> > 
> > Reported-by: Jan Stancek <jstancek@redhat.com>
> > Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
> 
> Applied.
> 

KASAN BUG message went away for me with this patch.

Regards,
Jan
