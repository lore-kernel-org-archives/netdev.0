From: Daniel Drake <dsd@gentoo.org>
Subject: Re: [PATCH] zd1211rw: Support for multicast addresses
Date: Thu, 30 Nov 2006 20:57:10 -0500
Message-ID: <456F8BF6.7020304@gentoo.org>
References: <20061201005807.C04067B409F@zog.reactivated.net> <20061130175036.35f0ccf7@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org,
	kune@deine-taler.de, benoit.papillault@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp131.iad.emailsrvr.com ([207.97.245.131]:28600 "EHLO
	smtp131.iad.emailsrvr.com") by vger.kernel.org with ESMTP
	id S1757011AbWLACEO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 21:04:14 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061130175036.35f0ccf7@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Why all the trouble do it off work queue? Is someone calling
> set_multicast_list with IRQ's disabled?

Register I/O involves sleeping, so we need to be in process context.

in_atomic() returns non-zero in the set_multicast_list handler. I 
couldn't tell you which codepath this is in.

Daniel
