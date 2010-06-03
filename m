From: Mitchell Erblich <erblichs@earthlink.net>
Subject: Re: 200 millisecond timeouts in TCP
Date: Thu, 3 Jun 2010 15:51:43 -0700
Message-ID: <D439C073-B9B9-4C09-8A6A-F0FDD325DAAB@earthlink.net>
References: <AANLkTils4KHXwX79cLG6UvVOaDdddMqx-1tyUL3VtLQC@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v1078)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: Ivan Novick <novickivan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-spurfowl.atl.sa.earthlink.net ([209.86.89.66]:54965
	"EHLO elasmtp-spurfowl.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756088Ab0FCWvp convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jun 2010 18:51:45 -0400
In-Reply-To: <AANLkTils4KHXwX79cLG6UvVOaDdddMqx-1tyUL3VtLQC@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jun 3, 2010, at 3:37 PM, Ivan Novick wrote:

> Hello,
> 
> Using tcpdump and systemtap I am seeing that sometimes retransmission
> of data is sent after waiting 200 milliseconds.  However sometimes
> retransmissions happen quicker.
> 
> Is there a specifc event that causes these 200 milisec delays to kick
> in?  Are those events identifiable in netstat -s output?
> 
> Also do you know if the timeout numbers for TCP are configurable parameters?
> 
> I am testing on RHEL5 with this kernel: 2.6.18-164.15.1.el5.
> 
> Cheers,
> Ivan Novick
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
Ivan Novick,

There is a public Linux TCP paper that I think covers this.

Mitchell Erblich