From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v3 03/10] net: Add netdev interfaces recording
 send/compl
Date: Wed, 23 Nov 2011 09:46:14 -0800
Message-ID: <20111123094614.36560215@nehalam.linuxnetplumber.net>
References: <alpine.DEB.2.00.1111222139560.14623@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56016 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752283Ab1KWRqR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Nov 2011 12:46:17 -0500
In-Reply-To: <alpine.DEB.2.00.1111222139560.14623@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Nov 2011 21:52:37 -0800 (PST)
Tom Herbert <therbert@google.com> wrote:

> Add interfaces for drivers to call for recording number of packets and
> bytes at send time and transmit completion.  Also, added a function to
> "reset" a queue.  These will be used by Byte Queue Limits.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Since all the drivers that you show do this for one packet at a time,
why bother with a packets arguement to netdev_sent_queue()?
