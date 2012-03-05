From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Marvell DSA switch 88E6165 - CPU port in PHY mode
Date: Mon, 5 Mar 2012 18:12:24 +0100
Message-ID: <20120305171224.GU12271@wantstofly.org>
References: <516EEEFC-DEEC-4CF5-BEF6-C5F3F86FCDD5@partychief.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "Matthew D. Smith" <mdsmith@partychief.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:62127 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756955Ab2CERM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 12:12:26 -0500
Content-Disposition: inline
In-Reply-To: <516EEEFC-DEEC-4CF5-BEF6-C5F3F86FCDD5@partychief.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 04, 2012 at 03:11:53PM +0100, Matthew D. Smith wrote:

> Hello - have a question about CPU port configuration in the net/dsa
> driver code. Can't seem to work out how to bring up the CPU connected
> port on the switch (in our case this is Port 4 hardware strapped with
> its embedded PHY enabled).

Hello!  I know of at least a couple of platforms that have a DSA chip
connected to the CPU via an MDI type link, but I'm not sure why it's
not working for you.  I'd suggest double-checking all the port 5 PHY
registers against the chip documentation..


thanks,
Lennert
