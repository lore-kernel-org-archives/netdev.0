From: Dan Williams <dcbw@redhat.com>
Subject: Re: bcm43xx driver unstable behaviour (and linux wireless is junk
	btw)
Date: Sun, 24 Sep 2006 12:02:03 -0400
Message-ID: <1159113723.9182.0.camel@localhost.localdomain>
References: <1159065798.5924.8.camel@localhost.localdomain>
	 <1159069857.2748.5.camel@localhost.localdomain>
	 <1159078386.5924.13.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:65481 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751187AbWIXQAQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Sep 2006 12:00:16 -0400
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1159078386.5924.13.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-09-24 at 16:13 +1000, Benjamin Herrenschmidt wrote:
> > prism54 fullmac, right?
> 
> Yes.
> 
> > Try using -Dwext; the prism54 wpa_supplicant driver is a dead-end and I
> > added WE-19 commands to it a bit ago anyway.  Oddly enough, I couldn't
> > seem to get the driver to work reliably for me using straight WEP
> > either, let alone WPA.  It's pretty unmaintained at the moment.
> 
> Ok, well, I tried with wext but iirc, I got rejected ioctls' from
> wpa_supplicant. I'll try again later. Thanks.

Ok, the changes appear to be in Linville's wireless-2.6 git tree, but
not yet in the netdev git tree.

Dan


