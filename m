From: Martin Bligh <mbligh@mbligh.org>
Subject: Re: [Changelog] - Potential performance bottleneck for Linxu TCP
Date: Wed, 29 Nov 2006 15:36:14 -0800
Message-ID: <456E196E.2080802@mbligh.org>
References: <HNEBLGGMEGLPMPPDOPMGCEAKCGAA.wenji@fnal.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, akpm@osdl.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dvhart.com ([64.146.134.43]:7369 "EHLO dvhart.com")
	by vger.kernel.org with ESMTP id S967420AbWK2XgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Nov 2006 18:36:15 -0500
To: wenji@fnal.gov
In-Reply-To: <HNEBLGGMEGLPMPPDOPMGCEAKCGAA.wenji@fnal.gov>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wenji Wu wrote:
> From: Wenji Wu <wenji@fnal.gov>
> 
> Greetings,
> 
> For Linux TCP, when the network applcaiton make system call to move data
> from
> socket's receive buffer to user space by calling tcp_recvmsg(). The socket
> will
> be locked. During the period, all the incoming packet for the TCP socket
> will go
> to the backlog queue without being TCP processed. Since Linux 2.6 can be
> inerrupted mid-task, if the network application expires, and moved to the
> expired array with the socket locked, all the packets within the backlog
> queue
> will not be TCP processed till the network applicaton resume its execution.
> If
> the system is heavily loaded, TCP can easily RTO in the Sender Side.


So how much difference did this patch actually make, and to what
benchmark?

> The patch is for Linux kernel 2.6.14 Deskop and Low-latency Desktop

The patch oesn't seem to be attached? Also, would be better to make
it for the latest kernel version (2.6.19) ... 2.6.14 is rather old ;-)

M
