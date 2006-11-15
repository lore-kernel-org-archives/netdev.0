From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [TG3]: Increase 5906 firmware poll time.
Date: Tue, 14 Nov 2006 16:05:50 -0800
Message-ID: <1163549150.4954.25.camel@rh4>
References: <1163544143.4954.19.camel@rh4> <455A4BB8.8060301@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, zambrano@broadcom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:41230 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S966457AbWKNXNl
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Nov 2006 18:13:41 -0500
To: "Jeff Garzik" <jeff@garzik.org>
In-Reply-To: <455A4BB8.8060301@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-11-14 at 18:05 -0500, Jeff Garzik wrote:

> 
> ACK, of course, but this brings up something else:  what's the status of 
> moving chip reset outside of a spinlock?
> 
> Currently a reset during operation can trigger the CPU lockup detector 
> and other doo-dads, because you can easily spend a second or two with a 
> spinlock held (a loooooong time, to hold a spinlock)
> 

Yeah, I will put this in my queue.  I have done some of that in the PHY
routines and will continue to do more, as those are even worse.

