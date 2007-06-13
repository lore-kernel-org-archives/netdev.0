From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 1/6] 8139too: force media setting cleanup
Date: Wed, 13 Jun 2007 13:09:29 -0400
Message-ID: <467024C9.5010300@garzik.org>
References: <200705232134.l4NLYcm2000578@shell0.pdx.osdl.net>	 <46560567.5060708@garzik.org> <1181739176.23954.23.camel@melchior>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	akpm@linux-foundation.org, leewkb@yahoo.com,
	netdev <netdev@vger.kernel.org>
To: Kyuma Ohta <whatisthis@jcom.home.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37686 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756931AbXFMRJd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2007 13:09:33 -0400
In-Reply-To: <1181739176.23954.23.camel@melchior>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kyuma Ohta wrote:
> Hi,
> I was testing 2.6.22-rc4 from yesterday,
> but communication speed  of 8139 side is very slower 
> than 2.6.21.* (less than 10kbytes/sec at  
> 100MBPS,FULL-DUPLEX).
> I was not test from 2.6.22-rc ,yesterday I started to test 2.6.22-rc.
> 
> So, I *must* set HALF-DUPLEX to 8139 side below:
> ethtool -s ethx speed 100 duplex half autoneg on 
> *x is number of 8139 assigned from udev.
> 
> So,Pls.apply this patch to upstream,and I test this too.

Your use of ethtool clearly demonstrates the lack of need for this patch.

	Jeff




