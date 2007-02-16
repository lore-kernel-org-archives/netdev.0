From: Rick Jones <rick.jones2@hp.com>
Subject: Re: degradation in bridging performance of 5% in 2.6.20 when compared
 to	2.6.19
Date: Fri, 16 Feb 2007 09:43:20 -0800
Message-ID: <45D5ED38.1070503@hp.com>
References: <9dd3c65d0702152226h6bfc4e22q3f3b04d97d8da1fb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kalyan tejaswi <kalyanatejaswi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:59305 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932621AbXBPRnY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Feb 2007 12:43:24 -0500
In-Reply-To: <9dd3c65d0702152226h6bfc4e22q3f3b04d97d8da1fb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

kalyan tejaswi wrote:
> Hi all,
> I have been comparing bridging performance for 2.6.20 and 2.6.19
> kernels. The kenel configurations are identical for both the kernels.
> I use D-Link cards (8139too driver) for the Malta 4Kc board.
> 
> The setup is:
> 
> netperf  client  <------->  malta 4Kc  <---------> netperf  server.
> 
> The throughput statistics (in 10^6 bits/second) are:
> 
>                    2.6.19          2.6.20
> routing            30.2           30.16
> bridging          32.35          30.81
> 
> I observe that there has been a degradation in bridging performance of
> 5% in 2.6.20 when compared to 2.6.19.
> 
> Has anyone observed similar behaviour?
> Any inputs or suggestions are welcome.

In each case is the malta CPU bound?  If not, some idea of the change in 
CPU util might be helpful.

rick jones
btw, netperf 2.4.3 just released:
ftp://ftp.netperf.org/netperf
http://www.netperf.org/svn/netperf2/tags/netperf-2.4.3
