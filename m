From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 0/9] Network receive deadlock prevention for NBD
Date: Wed, 09 Aug 2006 16:54:31 -0700 (PDT)
Message-ID: <20060809.165431.118952392.davem@davemloft.net>
References: <1155127040.12225.25.camel@twins>
	<20060809130752.GA17953@2ka.mipt.ru>
	<1155130353.12225.53.camel@twins>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	phillips@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:8122
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751345AbWHIXyt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 19:54:49 -0400
To: a.p.zijlstra@chello.nl
In-Reply-To: <1155130353.12225.53.camel@twins>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 09 Aug 2006 15:32:33 +0200

> The idea is to drop all !NFS packets (or even more specific only
> keep those NFS packets that belong to the critical mount), and
> everybody doing critical IO over layered networks like IPSec or
> other tunnel constructs asks for trouble - Just DON'T do that.

People are doing I/O over IP exactly for it's ubiquity and
flexibility.  It seems a major limitation of the design if you cancel
out major components of this flexibility.

I really can't take this work seriously when I see things like this
being said.
