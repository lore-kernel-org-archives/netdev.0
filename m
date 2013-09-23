From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 2/2] net: Use Toeplitz for IPv4 and IPv6 connection
 hashing
Date: Mon, 23 Sep 2013 16:11:15 -0700
Message-ID: <20130923161115.5d756838@nehalam.linuxnetplumber.net>
References: <alpine.DEB.2.02.1309231543330.23714@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:61273 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752684Ab3IWXLT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 19:11:19 -0400
Received: by mail-pd0-f179.google.com with SMTP id v10so3842457pde.10
        for <netdev@vger.kernel.org>; Mon, 23 Sep 2013 16:11:18 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1309231543330.23714@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Sep 2013 15:44:51 -0700 (PDT)
Tom Herbert <therbert@google.com> wrote:

> Toeplitz
>   IPv4
>     58.72% CPU utilization
>     110/146/198 90/95/99% latencies
>     1.72549e+06 tps
>   IPv6
>     72.38% CPU utilization
>     117/168/255 90/95/99% latencies
>     1.58545e+06 tps
> 
> Jhash
>   IPv4
>     57.67% CPU utilization
>     111/146/196 90/95/99% latencies
>     1.71574e+06 tps
>   IPv6
>     71.84% CPU utilization
>     117/166/248 90/95/99% latencies
>     1.59359e+06 tps

It looks slower and more complex than Jhash, what is the benefit?
Have you investigated using Murmur instead?
