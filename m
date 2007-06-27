From: David Hollis <dhollis@davehollis.com>
Subject: Re: Linksys Gigabit USB2.0 adapter (asix) regression
Date: Wed, 27 Jun 2007 01:54:52 -0400
Message-ID: <1182923692.6644.4.camel@dhollis-lnx.sunera.com>
References: <467915D9.3030900@slagter.name>
	<1182523020.4938.20.camel@dhollis-lnx.sunera.com>
	<467FF5DB.5090006@slagter.name>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Erik Slagter <erik@slagter.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms042pub.verizon.net ([206.46.252.42]:40119 "EHLO
	vms042pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756243AbXF0Fzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 01:55:35 -0400
Received: from smtp.davehollis.com ([71.251.104.159])
 by vms042.mailsrvcs.net (Sun Java System Messaging Server 6.2-6.01 (built Apr
 3 2006)) with ESMTPA id <0JKA00HDF5RN2WP4@vms042.mailsrvcs.net> for
 netdev@vger.kernel.org; Wed, 27 Jun 2007 00:54:59 -0500 (CDT)
In-reply-to: <467FF5DB.5090006@slagter.name>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-06-25 at 19:05 +0200, Erik Slagter wrote:
> drivers/net/usb/asix.c: PHYID=0x01410cc2

Ok, it is using a Marvell PHY so that part should be fine.  You
mentioned that it looks like the packets are being transmitted, but are
garbled in some way.  The device does prepend a 'header' to ethernet
packets as they are transmitted down the USB pipe.  The device strips
this off and puts the packets on the wire.  This could be where the
issue lies.  Are you on x86 by chance or something else?

-- 
David Hollis <dhollis@davehollis.com>

