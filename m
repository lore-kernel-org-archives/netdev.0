From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] bcm43xx-softmac: Further improvement in wireless	statistics
Date: Fri, 14 Jul 2006 12:09:50 -0500
Message-ID: <44B7CFDE.8050305@lwfinger.net>
References: <44B3CC25.7060305@lwfinger.net> <1152646370.27683.2.camel@localhost.localdomain> <44B474AF.6010907@lwfinger.net> <1152848265.2584.48.camel@localhost.localdomain> <20060714162517.GA21960@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dcbw@redhat.com>,
	John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:44230 "EHLO
	mtiwmhc12.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1161269AbWGNRJv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jul 2006 13:09:51 -0400
To: jt@hpl.hp.com
In-Reply-To: <20060714162517.GA21960@bougret.hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jean,

Jean Tourrilhes wrote:
> 
> 	I must admit that the original definition was too clever (or
> too ambiguous, or too original, take your pick). range->max_qual.level
> is always supposed to have a meaningfull value. People that did not
> understand that original definition just put 0 there, as it was the
> easiest way to output dBm.
> 	If you want more details, check the comment in the function
> iw_print_stats() in iwlib.c.
> 	As I say, range->max_qual.level is always supposed to have
> something useful, so :
> 
> if(IW_QUAL_DBM == 0)
> 	rssi level in the range [0 ; range->max_qual.level]
> if(IW_QUAL_DBM == 1)
> 	(rssi level - 256) in the range [range->max_qual.level - 256 ; 0]

Thank you for your explanation and the reference to the comment from wireless_tools. I think it is 
safe to say that we all have learned a lot. As you say, 8-bit arithmetic is tricky.

> 	I think WE-19 is old enough (most distro seems to use 2.6.16)
> that we don't have to bother about earlier version going forward.

I'm going to rely on that, set IW_QUAL_DBM, and choose the max_qual at 152, which corresponds to a 
floor-value of -104 dBm. The KDE applet display is a little strange as it displays -65 dBm at 
approximately 2/3 height, rather than the 1/3 value that I would expect. So far, I have not found 
the source for that applet and cannot verify the calculation. In any case, the display is acceptable 
even if not what I would expect. At least, the values in /proc/net/wireless are correct.

Thanks again,

Larry

