From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: Re: [PATCH 2.6.25] BNX2X: Correct bringing chip out of reset
Date: Wed, 09 Apr 2008 18:49:47 +0300
Message-ID: <1207756187.13326.27.camel@lb-tlvb-eliezer.il.broadcom.com>
References: <1207475082.13326.17.camel@lb-tlvb-eliezer.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2292 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753879AbYDIPt6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Apr 2008 11:49:58 -0400
In-Reply-To: <1207475082.13326.17.camel@lb-tlvb-eliezer.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sun, 2008-04-06 at 02:44 -0700, Eliezer Tamir wrote:
> BNX2X: Correct bringing chip out of reset
> 
> Fixed bug: Wrong register was written to when bringing the chip out of
> reset.
> 
I know that everyone has a huge backlog because of the recent problems
with vger.

Is is very important that this patch makes it into 2.6.25, since the bug
that it solves can be very painful on one hand, and on the other it is
very hard to trace. 
If you load the driver a second time without a full power down you will
not see any problem.

If it is needed I will gladly resubmit the patch.

Thanks
Eliezer


