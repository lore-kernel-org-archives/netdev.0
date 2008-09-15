From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [git patches] net driver fixes
Date: Mon, 15 Sep 2008 23:30:19 +0200
Message-ID: <m3od2p3xn8.fsf@maximus.localdomain>
References: <20080915201749.GB3994@havoc.gtf.org>
	<20080915.132716.267218808.davem@davemloft.net>
	<20080915204543.GD3994@havoc.gtf.org>
	<20080915.141442.139271313.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:58720 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754132AbYIOVaX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Sep 2008 17:30:23 -0400
In-Reply-To: <20080915.141442.139271313.davem@davemloft.net> (David Miller's message of "Mon\, 15 Sep 2008 14\:14\:42 -0700 \(PDT\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> Maybe a OOPS fix for common hardware.  But not for something
> like obscure WAN stuff.

FYI: the WAN bit was actually a regression, 2.6.26 doesn't have this
bug. Nevertheless generic HDLC especially with X.25 is not the
mainstream code so I guess it's probably perfectly acceptable to delay
the fix to minimize the patch flow.
-- 
Krzysztof Halasa
