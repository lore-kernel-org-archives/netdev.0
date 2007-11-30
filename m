From: Ariane Keller <ariane.keller@tik.ee.ethz.ch>
Subject: Re: [PATCH 0/2] netem: trace enhancement
Date: Fri, 30 Nov 2007 17:25:21 +0100
Message-ID: <47503971.9080509@ee.ethz.ch>
References: <20071120231131.oqn4s5eda84k4csw@email.ee.ethz.ch>	<474C2246.50205@ee.ethz.ch> <20071129134554.5c25a891@freepuppy.rosehill> <474F3719.30101@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Ariane Keller <ariane.keller@tik.ee.ethz.ch>,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	Rainer Baumann <baumann@tik.ee.ethz.ch>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ee.ethz.ch ([129.132.2.219]:59302 "EHLO smtp.ee.ethz.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762526AbXK3QZX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2007 11:25:23 -0500
In-Reply-To: <474F3719.30101@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks for your comments!

I'd like to better understand your dislike of the current implementation 
  of the data transfer from user space to kernel space.
Is it the fact that we use configfs?
I think, we had already a discussion about this (and we changed from 
procfs to configfs).
Or don't you like that we need a user space daemon which is responsible 
for feeding the data to the kernel module?
I think we do not have another option, since the trace file may be of 
arbitrary length.
Or anything else?




Patrick McHardy wrote:
> Stephen Hemminger wrote:
>> Still interested in this. I got part way through integrating it but had
>> concerns about the API from the application to netem for getting the 
>> data.
>> It seemed like there ought to be a better way to do it that could 
>> handle large
>> data sets better, but never really got a good solution worked out 
>> (that is why
>> I never said anything).
> 
> Would spreading them over multiple netlink messages work? A different,
> slightly ugly possibility would be to simply use copy_from_user, netlink
> is synchronous now (still better than using configfs IMO).
> 
