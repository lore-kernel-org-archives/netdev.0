From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [RFC PATCH] bcm43xx: set channel when the interface is brought
 up
Date: Thu, 25 Jan 2007 15:23:21 +0100
Message-ID: <20070125152321.434bb17c@griffin.suse.cz>
References: <1169707854.10593.41.camel@dv>
	<a32f33a40701250347q5c9aa5fby785181f77fc9bb4@mail.gmail.com>
	<20070125135033.7d7d7baf@griffin.suse.cz>
	<200701250905.33129.gene.heskett@verizon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, "Ivo Van Doorn" <ivdoorn@gmail.com>,
	netdev@vger.kernel.org
To: Gene Heskett <gene.heskett@verizon.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:40248 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965353AbXAYOXY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jan 2007 09:23:24 -0500
In-Reply-To: <200701250905.33129.gene.heskett@verizon.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 25 Jan 2007 09:05:32 -0500, Gene Heskett wrote:
> Oh?  I'm sitting here watching the tty0 screen of my lappy after x has 
> been started, and I have established a connection, but SoftMAC is still 
> logging its scan activity, starting with channel 1 and scanning 14 
> channels.  Its doing this at approximately 2 minute intervals.  So I 
> think we have your definition of a clear bug and misbehaviour.

Yes. As well as some other wireless drivers. But that's not worth
fixing.

Also, please note that softmac isn't going to do user space MLME so
it is not relevant at all.

 Jiri

-- 
Jiri Benc
SUSE Labs
