From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH 0/2][RFC] Network Event Notifier Mechanism
Date: Thu, 22 Jun 2006 15:40:16 -0500
Message-ID: <1151008816.3040.60.camel@stevo-desktop>
References: <20060621184519.10425.69175.stgit@stevo-desktop>
	 <20060622.015728.59653992.davem@davemloft.net>
	 <1150984380.27156.4.camel@stevo-desktop>
	 <1150990041.3040.6.camel@stevo-desktop>  <1151005381.5392.108.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from es335.com ([67.65.19.105]:23872 "EHLO mail.es335.com")
	by vger.kernel.org with ESMTP id S1161339AbWFVUkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 16:40:18 -0400
To: hadi@cyberus.ca
In-Reply-To: <1151005381.5392.108.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-06-22 at 15:43 -0400, jamal wrote:
> 
> No - what these 2 gents are saying was these events and infrastructure
> already exist. 

Notification of the exact events needed does not exist today.   

The key events, again, are:

- the neighbour entry mac address has changed.

- the next hop ip address (ie the neighbour) for a given dst_entry has
changed.

- the path mtu for a given dst_entry has changed.


Steve.

