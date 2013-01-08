From: Rick Jones <rick.jones2@hp.com>
Subject: Re: IPV4 TCP connection reset using iperf
Date: Tue, 08 Jan 2013 09:39:36 -0800
Message-ID: <50EC59D8.9000701@hp.com>
References: <CAAvRe=izMJWEFDcZYEoJCY2Em7NQKco4_6x1L7t4h2XSJf6_Sg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Madhvapathi Sriram <sriram.madhvapathi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0184.atlanta.hp.com ([15.193.32.61]:25158 "EHLO
	g6t0184.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756777Ab3AHRji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 12:39:38 -0500
In-Reply-To: <CAAvRe=izMJWEFDcZYEoJCY2Em7NQKco4_6x1L7t4h2XSJf6_Sg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/08/2013 06:41 AM, Madhvapathi Sriram wrote:
> Hi,
>
> I have recently migrated to kernel version 3.6.10 from 3.2.1. I was
> running iperf to routinely measure TCP throughput and I have been
> facing problems eversince. I am using a wireless interface.
>
> wireless client: iperf -s -i 1 -w 1024K
> wireless server: iperf -c 192.168.1.1 -i -1 -w 1024 -t 600
>
> While, the connection is maintained for sometime and the perf logs
> keep going. Randomly, the connection breaks with the server side
> resetting the connection. The tcp dump on the client shows RST sent by
> the server. Switching back to 3.2.1 works. This issue starts from
> kernel version 3.5 onnwards.
>
> I have tried to probe along some points to take a look at the air
> logs, tcpdump on either sides but to no clue - everything seems normal
> like, the tcp window values, very less/negligible retransmissions and
> so on. The RST is set abruptly and randomly (no definite time - may
> happen randomly).
>
> I am looking for some suggestions or pointers towards analyzing the issue.

I cannot imagine that iperf bulk transfer would look all that much 
different from netperf bulk transfer, but I suppose you could see if a 
netperf TCP_STREAM test with similar configuration settings encounters 
the same RST issues.  Or, for that matter, an equally long-lived FTP or 
scp transfer.

rick jones
