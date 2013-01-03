From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Is keepalive behaving as expected in 3.7.0+/net-next?
Date: Thu, 03 Jan 2013 12:13:39 -0800
Message-ID: <50E5E673.4070202@hp.com>
References: <50D4DD28.30903@hp.com> <1356645265.30414.1542.camel@edumazet-glaptop> <50df48f4.0e5b650a.36fa.1452@mx.google.com> <50E0A963.6080900@hp.com> <50e0ef55.11f2640a.4ef8.ffffd018@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <erdnetdev@gmail.com>, netdev@vger.kernel.org
To: Jamie Gloudon <jamie.gloudon@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:15115 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753430Ab3ACUNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2013 15:13:40 -0500
In-Reply-To: <50e0ef55.11f2640a.4ef8.ffffd018@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/30/2012 05:50 PM, Jamie Gloudon wrote:
> On Sun, Dec 30, 2012 at 12:51:47PM -0800, Rick Jones wrote:
>>> Make a lot of sense. However, I got the impression from Rick that
>>> having tcp_keepalive_intvl > tcp_keepalive_time behaved correctly in
>>> older versions of the kernel.
>>
>> I seek to make no assertions about the behaviour of older kernels.  I was
>> just going off the ip-sysctl.txt wording I was looking to clean-up.
>>
>> rick
>
> Ok, should ip-sysctl.txt documentation be updated to warn not to set tcp_keepalive_intvl > tcp_keepalive_time?

Well, that or explain how it will not always be the time interval at 
which the probes are sent.

rick
