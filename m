From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 17/20][BNX2]: Enhance the heartbeat.
Date: Wed, 02 May 2007 03:17:20 -0400
Message-ID: <46383B00.4080605@garzik.org>
References: <1178068656.4820.53.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56098 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992877AbXEBHRX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2007 03:17:23 -0400
In-Reply-To: <1178068656.4820.53.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> [BNX2]: Enhance the heartbeat.
> 
> In addition to the periodic heartbeat, we're adding a heartbeat
> request interrupt when the heartbeat is late.  This is useful
> especially in -rt kernels where the timer frequently runs late.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Should we really be adding code for such a special situation to upstream 
code?

I lean towards "no", but defer to your and DaveM's judgement here.


