From: Rick Jones <rick.jones2@hp.com>
Subject: Re: How I can reset TCP sockets after long suspend/resume cyscle
Date: Wed, 04 Jun 2008 14:23:37 -0700
Message-ID: <484707D9.3040900@hp.com>
References: <200806011515.14103.maximlevitsky@gmail.com>	<4846B5F2.8090805@gmail.com>	<396556a20806040909q7e5eb8abi7cbc8b5ed11ed54e@mail.gmail.com>	<484700A6.3020707@gmail.com> <20080604141533.35eb6df0@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Maxim Levitsky <maximlevitsky@gmail.com>,
	Adam Langley <agl@imperialviolet.org>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:2197 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751257AbYFDVXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 17:23:40 -0400
In-Reply-To: <20080604141533.35eb6df0@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Another idea would be for the kernel to prematurely run the keepalive
> timer for all TCP connections after resume. The keepalive code would send
> an ACK (out of window) which causes other side to send a RST or ACK.
> 
> It is normal behaviour, the change would just make the timer happen sooner.

Would you have it done even for those endpoints on which SO_KEEPALIVE 
wasn't set?

rick jones
