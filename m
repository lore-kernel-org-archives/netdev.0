From: Junio C Hamano <gitster@pobox.com>
Subject: Re: [GIT]: Networking
Date: Mon, 05 Jan 2009 23:00:53 -0800
Message-ID: <7v7i58or4q.fsf@gitster.siamese.dyndns.org>
References: <alpine.LFD.2.00.0901051839330.3057@localhost.localdomain>
 <20090105.201530.195720489.davem@davemloft.net>
 <alpine.LFD.2.00.0901052029220.3057@localhost.localdomain>
 <20090105.204934.65827705.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a-sasl-fastnet.sasl.smtp.pobox.com ([207.106.133.19]:62181 "EHLO
	sasl.smtp.pobox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750719AbZAFHBC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 02:01:02 -0500
In-Reply-To: <20090105.204934.65827705.davem@davemloft.net> (David Miller's
 message of "Mon, 05 Jan 2009 20:49:34 -0800 (PST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> That wouldn't have helped me in this case at all.
>
> I had 4 firmware patches to apply, each one had to add entries
> to the same file.
>
> The first patch had to be skipped.
>
> So the second one, which is the first one I added (which is the acenic
> bogon with the missed delete), is the one GIT wouldn't take but patch
> would.

What I typically do when I see myself in such a situation is to apply all
of four patches to a throw-away branch once, and then discard that branch
right away.  Then I can apply only the good three patches, skipping the
first one, and "am -3" would still apply.
