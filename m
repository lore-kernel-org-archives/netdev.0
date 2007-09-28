From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.23-rc8 network problem.  Mem leak?  ip1000a?
Date: Fri, 28 Sep 2007 02:20:51 -0700
Message-ID: <20070928022051.a6f27b1e.akpm@linux-foundation.org>
References: <20070928020617.7389.qmail@science.horizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: linux@horizon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:54350 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754599AbXI1JVD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 05:21:03 -0400
In-Reply-To: <20070928020617.7389.qmail@science.horizon.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 27 Sep 2007 22:06:17 -0400 linux@horizon.com wrote:

> Uniprocessor Althlon 64, 64-bit kernel, 2G ECC RAM,
> 2.6.23-rc8 + linuxpps (5.0.0) + ip1000a driver.
> (patch from http://marc.info/?l=linux-netdev&m=118980588419882)
> 
> After a few hours of operation, ntp loses the ability to send packets.
> sendto() returns -EAGAIN to everything, including the 24-byte UDP packet
> that is a response to ntpq.
> 
> ...
>
> Killing and restarting ntpd gets it running again for a few hours.
> Here's after about two hours of successful operation.  (I'll try to
> remember to run slabinfo before killing ntpd next time.)

ntpd.  Sounds like pps leaking to me.

> 
> Can anyone offer some diagnosis advice?
> 

CONFIG_DEBUG_SLAB_LEAK?
