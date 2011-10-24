From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFD] Network configuration data in sysfs
Date: Mon, 24 Oct 2011 04:34:07 +0300
Message-ID: <20111024013406.GA24158@shutemov.name>
References: <20111023233558.GA23264@shutemov.name>
 <20111023.204943.1509703901636083438.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, gregkh@suse.de,
	gladkov.alexey@gmail.com
To: David Miller <davem@davemloft.net>, kay.sievers@vrfy.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shutemov.name ([188.40.19.243]:40094 "EHLO shutemov.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752594Ab1JXBeI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Oct 2011 21:34:08 -0400
Content-Disposition: inline
In-Reply-To: <20111023.204943.1509703901636083438.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 23, 2011 at 08:49:43PM -0400, David Miller wrote:
> From: "Kirill A. Shutemov" <kirill@shutemov.name>
> Date: Mon, 24 Oct 2011 02:35:58 +0300
> 
> > Is there something fundamental preventing us to have sysfs interface for
> > network configuration?
> 
> Netlink already provides everything sysfs would potentially provide as
> well as event tracking.

Not everything. You still need special utilities to view/change the
configuration.

> udev could just listen to a netlink socket and notice all changes to
> addresses, routes, and device states.

Yes, potentially. I'm not sure if it fits well to udev design.
Kay, any comments?

-- 
 Kirill A. Shutemov
