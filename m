From: "Marcus D. Leech" <mleech@ripnet.com>
Subject: Re: Skipping past TCP lost packet in userspace
Date: Mon, 30 May 2011 23:30:41 -0400
Message-ID: <4DE460E1.5020103@ripnet.com>
References: <4DE44218.4070306@krellan.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Josh Lehan <linux@krellan.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta01.ripnet.com ([66.78.99.15]:52281 "EHLO mta01.ripnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752493Ab1EaDiu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 May 2011 23:38:50 -0400
In-Reply-To: <4DE44218.4070306@krellan.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> Hello.  I looked, but could not find an answer.  Is there already an
> ioctl() or something like that in Linux, that would allow a userspace
> TCP socket to skip past a lost packet?
>
> The kernel already will continue to queue up packets, and with TCP SACK,
> the kernel can acknowledge reception of further packets beyond the lost
> packet, allowing the queue to continue growing.  However, all these
> queued packets won't be delivered to userspace until the original lost
> packet is received again, after it has been retransmitted.
>
> Is there a way for a userspace program to prevent this needless stall?
> It would be great if there was an ioctl() or similar call, that would
> tell the kernel that it's OK to leave a gap in the data stream, and
> resume supplying userspace with more data.  An obvious application would
> be media streaming, and many high-level media protocols do their own
> block framing anyway, so resynchronization after the data gap would not
> be a problem.
>
> This sounds like something that would be a FAQ, and if so, please point
> me to the answer.  Thank you!
>
>   
This sounds like you want UDP, not TCP.

Unless I'm misunderstanding what you want, you want a protocol that has
a different "contract"
  than TCP.  Doing what you want basically requires breaking TCP.  That
isn't going to happen.




-- 
Principal Investigator
Shirleys Bay Radio Astronomy Consortium
http://www.sbrac.org


