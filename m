From: Ayaz Abdulla <AAbdulla@nvidia.com>
Subject: RE: [PATCH] forcedeth: mgmt unit interface changes
Date: Tue, 27 Jan 2009 17:34:45 -0800
Message-ID: <1FC56210173BB445BD77F608D6FB8D030294133FF8@HQMAIL03.nvidia.com>
References: <20090127.172944.219399602.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "manfred@colorfullife.com" <manfred@colorfullife.com>,
	"jgarzik@pobox.com" <jgarzik@pobox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'David Miller' <davem@davemloft.net>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:8954 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751365AbZA1BfZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 20:35:25 -0500
In-Reply-To: <20090127.172944.219399602.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes, good catch. One extra zero added, should be only upto 5 secs.

I will resend the patch.

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net]
Sent: Tuesday, January 27, 2009 5:30 PM
To: akpm@linux-foundation.org
Cc: Ayaz Abdulla; manfred@colorfullife.com; jgarzik@pobox.com; netdev@vger.kernel.org
Subject: Re: [PATCH] forcedeth: mgmt unit interface changes


From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 27 Jan 2009 17:27:05 -0800

> whee, a 50 second busy-wait.
>
> Unnecessarily, afacit.  The sole caller calls this function from
> ->probe without any locks held?
>
> I'd suggest that we
>
> a) use schedule_timeout_uninterruptible(1) and
>
> b) add a bit of user feedback (printk(".")?) so they don't get bored
> and hit the reset button (remember those?)

Agreed.
-----------------------------------------------------------------------------------
This email message is for the sole use of the intended recipient(s) and may contain
confidential information.  Any unauthorized review, use, disclosure or distribution
is prohibited.  If you are not the intended recipient, please contact the sender by
reply email and destroy all copies of the original message.
-----------------------------------------------------------------------------------
