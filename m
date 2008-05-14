From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH v2] Re: WAN: new PPP code for generic HDLC
Date: Wed, 14 May 2008 14:45:24 +0200
Message-ID: <m3lk2djbq3.fsf@maximus.localdomain>
References: <20080424.065555.30390704.davem@davemloft.net>
	<m3ve27nfpx.fsf@maximus.localdomain>
	<20080424214457.1d5a1655@the-village.bc.nu>
	<20080512.033244.153113922.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alan@lxorguk.ukuu.org.uk, jeff@garzik.org, paulkf@microgate.com,
	jchapman@katalix.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from OSB1387.piap.pl ([195.187.100.11]:60505 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761432AbYENMp1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2008 08:45:27 -0400
In-Reply-To: <20080512.033244.153113922.davem@davemloft.net> (David Miller's message of "Mon\, 12 May 2008 03\:32\:44 -0700 \(PDT\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> No
> locking at all over the HDLC protocol list, yikes!

Right, I didn't think about ioctl() vs insmod/rmmod races. Will fix
when I'm back home and can test it, in few days.
-- 
Krzysztof Halasa
