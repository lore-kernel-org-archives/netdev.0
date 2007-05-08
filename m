From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/4] s390: qeth driver connection hang
Date: Tue, 08 May 2007 01:17:31 -0400
Message-ID: <464007EB.2020308@garzik.org>
References: <20070502131331.GA13217@de.ibm.com> <20070502131711.GA25700@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: Frank Pavlic <fpavlic@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54347 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967903AbXEHFRe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 01:17:34 -0400
In-Reply-To: <20070502131711.GA25700@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Frank Pavlic wrote:
> From: Ursula Braun <braunu@de.ibm.com>
>       Frank Pavlic <fpavlic@de.ibm.com>
>       
> Connection hangs when using EDDP mode because sk_protocol is NULL
> when skb has been copied via skb_copy. This results in dropping 
> packets.
> Also keep MAC address after recovery of Virtual NICs so that
> traffic can flow again and duplicate statements in 
> qeth_dev_set_route_store removed.
> 
> Signed-off-by: Ursula Braun <braunu@de.ibm.com>
> Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
> ---
>  qeth_eddp.c |    4 ++--
>  qeth_eddp.h |    3 ++-
>  qeth_main.c |    5 +++--
>  qeth_sys.c  |    2 --
>  4 files changed, 7 insertions(+), 7 deletions(-)

applied 1-4


