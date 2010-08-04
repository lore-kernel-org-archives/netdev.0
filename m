From: Rick Jones <rick.jones2@hp.com>
Subject: Re: can TCP socket send buffer be over used?
Date: Tue, 03 Aug 2010 17:30:44 -0700
Message-ID: <4C58B4B4.6010904@hp.com>
References: <AANLkTi=Ma2yMVbgRnUUB6T1j=rHLb60oAXqCSbM35KgT@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jack Zhang <jack.zhang2011@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0185.atlanta.hp.com ([15.193.32.62]:45236 "EHLO
	g6t0185.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932233Ab0HDAjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 20:39:11 -0400
In-Reply-To: <AANLkTi=Ma2yMVbgRnUUB6T1j=rHLb60oAXqCSbM35KgT@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jack Zhang wrote:
> I understand that when the buffer size is set to 128 KB, I actually
> got a buffer of 256 KB as the kernel doubles the buffer size. I also
> understand that half the doubled buffer size is used for meta data
> instead of the actual data to be transferred. So basically the
> effective buffer sizes for the two examples  are just 128 KB and 512
> KB respectively.

It may not be strictly 1/2.  One way to check would be to take a tcpdump trace 
on the sending side, and either work-out manually the most the connection has 
outstanding at a time, or run the binary trace through something like tcptrace.

rick jones
