From: David Miller <davem@davemloft.net>
Subject: Re: [TG3]: Increase 5906 firmware poll time.
Date: Tue, 14 Nov 2006 16:34:12 -0800 (PST)
Message-ID: <20061114.163412.25474073.davem@davemloft.net>
References: <1163544143.4954.19.camel@rh4>
	<455A4BB8.8060301@garzik.org>
	<1163549150.4954.25.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, zambrano@broadcom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:16330
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S966539AbWKOAeL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Nov 2006 19:34:11 -0500
To: mchan@broadcom.com
In-Reply-To: <1163549150.4954.25.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 14 Nov 2006 16:05:50 -0800

> On Tue, 2006-11-14 at 18:05 -0500, Jeff Garzik wrote:
> 
> > 
> > ACK, of course, but this brings up something else:  what's the status of 
> > moving chip reset outside of a spinlock?
> > 
> > Currently a reset during operation can trigger the CPU lockup detector 
> > and other doo-dads, because you can easily spend a second or two with a 
> > spinlock held (a loooooong time, to hold a spinlock)
> > 
> 
> Yeah, I will put this in my queue.  I have done some of that in the PHY
> routines and will continue to do more, as those are even worse.

Great.

I applied this patch, thanks everyone.
