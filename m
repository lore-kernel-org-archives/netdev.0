From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] [resend] drivers/net: remove network drivers' last few
 uses of IRQF_SAMPLE_RANDOM
Date: Sat, 14 Jun 2008 05:43:10 -0400
Message-ID: <485392AE.7020501@garzik.org>
References: <Pine.LNX.4.62.0806132238340.728@ikari.dreamhost.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Chris Peterson <cpeterso@cpeterso.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38184 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755886AbYFNJnO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Jun 2008 05:43:14 -0400
In-Reply-To: <Pine.LNX.4.62.0806132238340.728@ikari.dreamhost.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Peterson wrote:
> Remove network drivers' last few uses of theoretically-exploitable network
> entropy. Only 12 net drivers are affected. Headless boxes should use a
> more secure source of entropy, such as userspace daemons like rngd, 
> clrngd, audio_entropyd, and/or video_entroyd.
> 
> 
> Signed-off-by: Chris Peterson <cpeterso@cpeterso.com>

For what it's worth...  I'm keeping this patch in my 'hold' queue, 
mainly to see if anyone really puts up some major objections, or fuss.

I'm leaning towards applying it for 2.6.27...

	Jeff



