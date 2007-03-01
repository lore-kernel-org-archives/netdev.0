From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: CLOCK_MONOTONIC datagram timestamps by the kernel
Date: Thu, 1 Mar 2007 17:13:50 +0100
Message-ID: <200703011713.50522.dada1@cosmosbay.com>
References: <45E5570E.7050301@free.fr> <200703011230.50596.dada1@cosmosbay.com> <45E6F744.8070106@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: John find <linux.kernel@free.fr>, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:58576 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965315AbXCAQN5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2007 11:13:57 -0500
In-Reply-To: <45E6F744.8070106@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 01 March 2007 16:54, Stephen Hemminger wrote:
>
> I like it except changing stamp to stampns all over the place is
> unnecessary, just change the
> type.

Well... After seeing the compat code using casts, I felt some external users 
could try to cast it as well and not detect the new type...

>
> I assume old tcpdump works as expected.

Yes, of course...
