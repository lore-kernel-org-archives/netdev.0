From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.17: networking bug??
Date: Tue, 13 Jun 2006 16:01:52 -0700 (PDT)
Message-ID: <20060613.160152.84363218.davem@davemloft.net>
References: <448F32E1.8080002@rtr.ca>
	<20060613.152301.26928146.davem@davemloft.net>
	<448F3EF5.50701@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lkml@rtr.ca, jheffner@psc.edu, torvalds@osdl.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:55988
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751175AbWFMXBq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jun 2006 19:01:46 -0400
To: rick.jones2@hp.com
In-Reply-To: <448F3EF5.50701@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Tue, 13 Jun 2006 15:40:53 -0700

> > One final word about window sizes.  If you have a connection whose
> > bandwidth-delay-product needs an N byte buffer to fill, you actually
> > have to have an "N * 2" sized buffer available in order for fast
> > retransmit to work.
> 
> Is that as important in the presence of SACK?

The consern is identical, SACK or not.

The only difference SACK introduces for fast retransmit is that we
know with more certainty which holes need to be filled and thus which
packets to fast retransmit.
