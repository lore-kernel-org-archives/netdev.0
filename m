From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2 2/2] iproute2: use libgenl in ipl2tp
Date: Tue, 11 Sep 2012 23:22:41 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1209112304410.2023@ja.ssi.bg>
References: <1347354274-3119-1-git-send-email-ja@ssi.bg> <1347354274-3119-3-git-send-email-ja@ssi.bg> <20120911090908.605d1fbe@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:50605 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751329Ab2IKUSt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Sep 2012 16:18:49 -0400
In-Reply-To: <20120911090908.605d1fbe@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 11 Sep 2012, Stephen Hemminger wrote:

> On Tue, 11 Sep 2012 12:04:34 +0300
> Julian Anastasov <ja@ssi.bg> wrote:
> 
> > 	Use the common code from libgenl.c to parse family.
> > 
> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> 
> I applied these two but made some modifications:
>   1. change to GENL_INITIALIZER
>   2. use GENL_INITIALIZER

	I used 2 defines, so that in tcp_metrics.c I can
use different initialization depending on the command.
But as the structure is unnamed may be it is better to have
single define (both defines merged as you proposed) and
later just to update cmd and flags if needed.

Regards

--
Julian Anastasov <ja@ssi.bg>
