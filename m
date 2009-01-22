From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: sky2 hang with 2.6.28 and 2.6.29-rc2
Date: Fri, 23 Jan 2009 08:38:42 +1100
Message-ID: <20090123083842.253f68c4@s6510>
References: <3876.87.196.10.75.1232658152.squirrel@webmail.decimal.pt>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Jorge Bastos" <mysql.jorge@decimal.pt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50046 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752474AbZAVVjV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2009 16:39:21 -0500
In-Reply-To: <3876.87.196.10.75.1232658152.squirrel@webmail.decimal.pt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 22 Jan 2009 21:02:32 -0000 (WET)
"Jorge Bastos" <mysql.jorge@decimal.pt> wrote:

> Hi,
> I've noticed with the kernel's (two different machines) 2.6.28 and
> 2.6.29-rc2, that the NIC's were hanging.
> 
> In the kernel output i have:
> ---
> sky2 eth0: receiver hang detected
> sky2 eth0: disabling interface
> sky2 eth0: enabling interface
> sky2 eth0: Link is up at 1000 Mbps, full duplex, flow control rx
> ---

Marvell ram fifo has hardware problem where if it gets full it hangs.
The driver snoops to look for this, and the should recover. Unfortunately,
the recovery may take long enough to disturb connections.
