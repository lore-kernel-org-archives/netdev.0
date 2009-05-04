From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [iproute2 patch]: Add 'ip tuntap' facility for managing
 tun/tap devices
Date: Mon, 04 May 2009 15:49:19 +0100
Message-ID: <1241448559.6126.110.camel@macbook.infradead.org>
References: <1241433136.6126.70.camel@macbook.infradead.org>
	 <1241433778.6126.90.camel@macbook.infradead.org>
	 <20090504073813.19d0d624@nehalam>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37798 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757387AbZEDOtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 10:49:21 -0400
In-Reply-To: <20090504073813.19d0d624@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-05-04 at 07:38 -0700, Stephen Hemminger wrote:
> I would rather provide a netlink for managing TUNTAP interfaces

I'm not sure that makes a lot of sense. We'd be adding a new, duplicate
user API solely for the benefit of iproute2; it's not as if we'd ever be
able to get rid of the existing interface that everyone uses.

Unless you want to ditch the /dev/net/tun chardev completely and do
_everything_ over netlink, maybe... but that doesn't seem particularly
worthwhile either.

>  and reorganize under ip link??

It seemed more intuitive to model it after 'ip tunnel'. How would you
want it to look?

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

