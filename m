From: David Miller <davem@redhat.com>
Subject: Re: [PATCH V4 net-next 1/3] ipv6: add the IPV6_FL_F_REFLECT flag
 to IPV6_FL_A_GET
Date: Sun, 19 Jan 2014 17:12:48 -0800 (PST)
Message-ID: <20140119.171248.1412746430650359143.davem@redhat.com>
References: <1389975305-12477-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: florent.fourcot@enst-bretagne.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60865 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752166AbaATBMz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jan 2014 20:12:55 -0500
In-Reply-To: <1389975305-12477-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Date: Fri, 17 Jan 2014 17:15:03 +0100

> With this option, the socket will reply with the flow label value read
> on received packets.
> 
> The goal is to have a connection with the same flow label in both
> direction of the communication.
> 
> Changelog of V4:
>  * Do not erase the flow label on the listening socket. Use pktopts to
>  store the received value
> 
> Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>

Applied.
