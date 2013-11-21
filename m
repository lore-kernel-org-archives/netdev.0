From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: Question about IPv6 neighbor discovery and 6lowpan
Date: Thu, 21 Nov 2013 16:34:15 +0100
Message-ID: <20131121153414.GA9960@omega>
References: <1385046178.2723.17.camel@jrissane-mobl.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:43920 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751663Ab3KUPeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 10:34:22 -0500
Received: by mail-wg0-f50.google.com with SMTP id k14so10836829wgh.5
        for <netdev@vger.kernel.org>; Thu, 21 Nov 2013 07:34:20 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1385046178.2723.17.camel@jrissane-mobl.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jukka,

On Thu, Nov 21, 2013 at 05:02:58PM +0200, Jukka Rissanen wrote:
> Hi,
> 
> I am investigating RFC 6775 (Neighbor Discovery Optimization for IPv6
> over Low-Power Wireless Personal Area Networks (6LoWPANs))
> http://tools.ietf.org/html/rfc6775
> 
> The RFC suggests some changes to neighbor discovery procedure for the
> 6LoWPAN networks. I was looking net/ipv6/ndisc.c and it seems that
> ARPHRD type (from type field in net_device struct) is the only way to
> detect and change the discovery procedure in the ndisc.c code. Am I
> right with this assumption here?
> 
I think you are right, there was some patches on linux-zigbee-devel who
use exact the same idea to check the ARPHRD type.

But I am investigating for rfc6775, too. :-)


At the moment I see too many unsolved issues in the ieee802154/6lowpan
implementation which should be fixed at first. :(

- Alex
