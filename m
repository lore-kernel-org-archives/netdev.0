From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH V4 net-next 1/3] ipv6: add the IPV6_FL_F_REFLECT flag to IPV6_FL_A_GET
Date: Sun, 19 Jan 2014 15:57:25 +0100
Message-ID: <20140119145725.GA19818@order.stressinduktion.org>
References: <1389975305-12477-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:49538 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752163AbaASO51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jan 2014 09:57:27 -0500
Content-Disposition: inline
In-Reply-To: <1389975305-12477-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 17, 2014 at 05:15:03PM +0100, Florent Fourcot wrote:
> With this option, the socket will reply with the flow label value read
> on received packets.
> 
> The goal is to have a connection with the same flow label in both
> direction of the communication.
> 
> Changelog of V4:
>  * Do not erase the flow label on the listening socket. Use pktopts to
>  store the received value

This approach looks good!

> Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,

  Hannes
