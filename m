From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] sctp: SCTP_SOCKOPT_PEELOFF return socket pointer
 for kernel users
Date: Mon, 13 Jul 2015 12:58:52 -0700 (PDT)
Message-ID: <20150713.125852.915617134904684689.davem@davemloft.net>
References: <20150713103911.GA9631@hmsreliant.think-freely.org>
	<20150713.115912.324798425601463403.davem@davemloft.net>
	<55A40BF7.7060803@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org, vyasevich@gmail.com
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43679 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752406AbbGMT6z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 15:58:55 -0400
In-Reply-To: <55A40BF7.7060803@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Mon, 13 Jul 2015 16:05:27 -0300

> On 13-07-2015 15:59, David Miller wrote:
>> From: Neil Horman <nhorman@tuxdriver.com>
>> Date: Mon, 13 Jul 2015 06:39:11 -0400
>>
>>> Initially Marcelo had created duplicate code paths, one to return an
>>> fd, one to return a file struct.  If you would rather go in that
>>> direction, I'm sure he can propose it again, but that seems less
>>> correct to me than this solution.
>>
>> That's much better.
> 
> I'm not sure what you mean. Is the new option better or the
> history/description?

I mean that adding an explicit function for these internal kernel
users to call is better.
