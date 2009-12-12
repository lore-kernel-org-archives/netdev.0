From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Kernel Panics in the network stack
Date: Fri, 11 Dec 2009 19:44:17 -0500
Message-ID: <20091212004417.GA13690@hmsreliant.think-freely.org>
References: <4B22B4F2.8080605@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Kevin Constantine <kevin.constantine@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:35649 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761526AbZLLAoP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2009 19:44:15 -0500
Content-Disposition: inline
In-Reply-To: <4B22B4F2.8080605@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 11, 2009 at 01:09:06PM -0800, Kevin Constantine wrote:
> Hey Everyone-
>
> I've been playing with an ARM based linuxstamp  
> http://opencircuits.com/Linuxstamp, and I've been seeing kernel panics  
> with both 2.6.28.3, and 2.6.30 within an hour or so of turning the  
> linuxstamp on.  The stack traces always seem to point at functions  
> related to networking.  I've pasted a couple of the crash outputs below.  
>  The linuxstamp isn't typically doing anything when the crashes occur,  
> in fact it'll crash even if I haven't logged in.
>
> If I ifconfig the interface down, the linuxstamp stays up indefinitely.  
> Any pointers in one direction or another would be much appreciated.
>
> I'm not sure if this is the right audience to help out or if the arm  
> lists might be better.  But in any event, any help would be really  
> appreciated.
>
>
Might be worth turning on slab debugging to see if you get any violations on
slabs prior to your oops.  I was just debugging something simmilar on e1000e,
and slab debug was an immense help

Neil

>
