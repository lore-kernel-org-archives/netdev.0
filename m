From: Roland Dreier <rdreier@cisco.com>
Subject: Re: e1000 under VMware doesn't work since 2.6.27.16 - BISECTED
Date: Fri, 20 Mar 2009 16:03:58 -0700
Message-ID: <adafxh7yext.fsf@cisco.com>
References: <49C3C726.4000405@bcsoft.de>
	<20090320.155739.93629479.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: drifter@bcsoft.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3.cisco.com ([171.71.176.72]:18503 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751069AbZCTXEA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 19:04:00 -0400
In-Reply-To: <20090320.155739.93629479.davem@davemloft.net> (David Miller's
	message of "Fri, 20 Mar 2009 15:57:39 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > > we're using virtual machines under VMware with the e1000 emulated
 > > network card.

 > Sounds like vmware doesn't emulate the e1000 accurately enough.

I would consider problems with the vmware emulated e1000 to be similar
to hardware quirks in some other chip rev supported by the e1000
driver.  If a driver change broke e1000 inside a vmware VM then we
should probably fix the kernel if possible (although vmware probably
wants to improve their emulation too).

 - R.
