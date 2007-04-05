From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] ethtool: additional 10Gig niceness
Date: Thu, 05 Apr 2007 10:06:05 -0700
Message-ID: <46152C7D.4020807@hp.com>
References: <460968FD.4020202@hp.com> <460973A0.8020803@garzik.org>	<461443C4.2090702@hp.com> <4614AEB2.9000905@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:46998 "EHLO palrel13.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753333AbXDERGI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Apr 2007 13:06:08 -0400
In-Reply-To: <4614AEB2.9000905@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> applied

Thanks.

One thing I noticed while making the changes is that the reported speed 
is kept in a u16.  With 10G we are already 1/6 of the way to the 
maximum.  I've no idea when 100G will arrive, but euros to beliners it 
will probably arrive "some day" which means something will have to give.

I've not thought it through completely, but my initial reaction would be 
to suggest just making the thing a 64 bit quantity reporting bits and 
not worry about it again.  And then one doesn't have to worry if ethtool 
starts being applied to links which do not run at integral multiples of 
a Mbit/s.

rick jones
