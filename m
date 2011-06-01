From: "juice" <juice@swagman.org>
Subject: Re: Skipping past TCP lost packet in userspace
Date: Wed, 1 Jun 2011 22:36:32 +0300
Message-ID: <e424e4f368f54756a04b0e30f296882d.squirrel@www.liukuma.net>
References: <4DE44218.4070306@krellan.com>
    <BANLkTinKORbHHZ7dAqfiFOg5rqB77DcJY8D7AxmP-xwhwmOgGg@mail.gmail.com>
    <4DE5F3E3.2080609@krellan.com>
Reply-To: juice@swagman.org
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: "Josh Lehan" <linux@krellan.com>,
	"Yuchung Cheng" <ycheng@google.com>,
	"Josh Lehan" <linux@krellan.com>,
	"netdev" <netdev@vger.kernel.org>, jiyengar@fandm.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.liukuma.net ([62.220.235.15]:14176 "EHLO www.liukuma.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758929Ab1FAToU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jun 2011 15:44:20 -0400
In-Reply-To: <4DE5F3E3.2080609@krellan.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Nice, thanks for pointing me to this.  I appreciate the helpful answer,
> instead of just saying "use UDP" or "use SCTP".  That's not the point.
>
> For better or for worse, TCP is realistically the only viable protocol
> for streaming to the largest possible audience these days, hence my
> question about adding this feature to the Linux TCP implementation.
>

For better or for worse, I think the problem in your proposal is that it
just will not be portable, even if you implemented it on Linux stack.
I am quite sure you will not be able to bend other operating systems to
accept this kind of kludge in the TCP stack so the benefits are minimal.

The correct way to address this problem is to make sure that end-to-end
connectivity of all the needed protocols is maintained.


