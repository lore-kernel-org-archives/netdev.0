From: David Miller <davem@davemloft.net>
Subject: Re: Zero checksum in netconsole/netdump packets
Date: Tue, 07 Nov 2006 14:56:34 -0800 (PST)
Message-ID: <20061107.145634.112290263.davem@davemloft.net>
References: <454FC80B.9090001@redhat.com>
	<20061106.231603.15264009.davem@davemloft.net>
	<45508B0C.5020109@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:46019
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1753817AbWKGW4d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Nov 2006 17:56:33 -0500
To: clalance@redhat.com
In-Reply-To: <45508B0C.5020109@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Lalancette <clalance@redhat.com>
Date: Tue, 07 Nov 2006 08:33:00 -0500

> David Miller wrote:
> > From: Chris Lalancette <clalance@redhat.com>
> > Date: Mon, 06 Nov 2006 18:40:59 -0500
> > 
> >>      Assuming that this is just an oversight, attached is a simple
> >>      patch to compute the UDP checksum in netpoll_send_udp.
> > 
> > If the resulting checksum is zero, you should set it to
> > all 1's, like the real UDP code does.
> 
> David,
>      Ah, thanks.  Forgot about that.  I re-spun the patch with the change (attached).  I also moved the UDP checksum calculation up to where the rest of the UDP header setup is, to make it more consistent.
> 
> Thanks again for the comments!
> 
> Signed-off-by: Chris Lalancette <clalance@redhat.com>

Looks good, applied, thanks Chris.
