From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] netxen: deinline and sparse fix
Date: Tue, 10 Jul 2007 12:42:08 -0400
Message-ID: <4693B6E0.6010900@garzik.org>
References: <20070705161355.47694009@freepuppy.localdomain.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dhananjay Phadke <dhananjay@netxen.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60169 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754609AbXGJQmL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 12:42:11 -0400
In-Reply-To: <20070705161355.47694009@freepuppy.localdomain.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Get rid of dubious casts to (void *) which causes a sparse warning.
> And move largeish function from inline to the one file that uses the code,
> the compiler can then decide to inline it.
> 
> Compile tested only.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

applied


