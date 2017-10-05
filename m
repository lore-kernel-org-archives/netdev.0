From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/1] [net] bonding: Add NUMA notice
Date: Thu, 5 Oct 2017 23:46:36 +0200
Message-ID: <20171005214636.GM13247@lunn.ch>
References: <1507235025-21689-1-git-send-email-ptalbert@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Patrick Talbert <ptalbert@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:42106 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751381AbdJEVqi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Oct 2017 17:46:38 -0400
Content-Disposition: inline
In-Reply-To: <1507235025-21689-1-git-send-email-ptalbert@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 05, 2017 at 04:23:45PM -0400, Patrick Talbert wrote:
> Network performance can suffer when a load balancing bond uses slave
> interfaces which are in different NUMA domains.
> 
> This compares the NUMA domain of a newly enslaved interface against any
> existing enslaved interfaces and prints a warning if they do not match.

Hi Patrick

Is there a bonding mode which might actually want to do this? Send on
the local domain, unless it is overloaded, in which case send it to
the other domain?

There is also this talk for netdev:

https://netdevconf.org/2.2/session.html?shochat-devicemgmt-talk

	Andrew
