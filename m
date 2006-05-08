From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: 2.4 kern: want to print TCP cwnd with every packet
Date: Mon, 8 May 2006 10:31:23 -0700
Message-ID: <20060508103123.38b10e56@localhost.localdomain>
References: <28365.128.237.227.255.1146925156.squirrel@128.237.227.255>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:12233 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932497AbWEHRbh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 May 2006 13:31:37 -0400
To: "George P Nychis" <gnychis@cmu.edu>
In-Reply-To: <28365.128.237.227.255.1146925156.squirrel@128.237.227.255>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 6 May 2006 10:19:16 -0400 (EDT)
"George P Nychis" <gnychis@cmu.edu> wrote:

> Hi,
> 
> I'd like to print the TCP cwnd for the sender, with every packet before it is sent out.  This way i could plot the sender window over time to show TCP's behavior in certain conditions.
> 
> I see in tcp_input.c several places where i could print the current window, but i'd have to add code in multiple places.  I was wondering if there is any 1 place, right before a packet is sent out, that i could printk() tp->snd_cwnd
> 
> Thanks!
> George
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Look at http://developer.osdl.org/shemminger/prototypes/tcpprobe.tar.gz
