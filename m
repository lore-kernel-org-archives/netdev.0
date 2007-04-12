From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: TCP connection stops after high load.
Date: Wed, 11 Apr 2007 21:06:24 -0400
Message-ID: <20070412010624.GO13621@kvack.org>
References: <461D2DEA.4010806@candelatech.com> <461D447C.4070408@candelatech.com> <20070411.134804.50594117.davem@davemloft.net> <461D4DD7.7020207@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:48916 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753805AbXDLBG0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2007 21:06:26 -0400
Content-Disposition: inline
In-Reply-To: <461D4DD7.7020207@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 11, 2007 at 02:06:31PM -0700, Ben Greear wrote:
> For the dup acks, I see nothing *but* dup acks on the wire...going in
> both directions interestingly, at greater than 100,000 packets per second.
> 
> I don't mind adding printks...and I've started reading through the code,
> but there is a lot of it, and indiscriminate printks will likely just
> hide the problem because it will slow down performance so much.

What do the timestamps look like?  PAWS contains logic which will drop 
packets if the timestamps are too old compared to what the receiver 
expects.

		-ben
-- 
"Time is of no importance, Mr. President, only life is important."
Don't Email: <zyntrop@kvack.org>.
