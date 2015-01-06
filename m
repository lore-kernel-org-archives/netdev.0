From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: IPsec workshop at netdev01?
Date: Tue, 6 Jan 2015 11:19:37 +0100
Message-ID: <20150106101936.GC31458@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:34550 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751098AbbAFKTu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2015 05:19:50 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is there any interest in doing an IPsec workshop at netdev01?

This mail is to probe if we can gather enough discussion topics to run
such a workshop. So if someone is interested to attend and/or has a
related discussion topic, please let me know.

The idea to do this workshop came yesterday, so I'm still collecting
topics I'm interested in. Some things that came immediately to my mind
are:

- Our IPsec policy/state lookups are still hashlist based on slowpath with
  a flowcache to do fast lookups for traffic flows we have already seen.
  This flowcache has similar issues like the ipv4 routing chache had.
  Is the flowcache an appropriate lookup method on the long run or should
  we at least think about an additional alternative lookup method?

- We still lack a 32/64 bit compatibiltiy layer for IPsec, this issue
  comes up from time to time. Some solutions were proposed in the past
  but all had problems. The current behaviour is broken if someone tries
  to configure IPsec with 32 bit tools on a 64 bit machine. Can we get
  this right somehow or is it better to just return an error in this case?

- Changing the system time can lead to unexpected SA lifetime changes. The
  discussion on the list did not lead to a conclusion on how to fix this.
  What is the best way to get this fixed?
  
- The IPsec policy enforcement default is to allow all flows that don't
  match a policy. On systems with a high security level it might be
  intersting to configurable invert the default from allow to block. With
  the default to block configured, we would need allow policies for all
  packet flows we accept. Some people would be even interested in a knob
  to enforce a certain default behaviour until the next reboot. Is this
  reasonable? How far can we get here?

- A more general thing: How complete is our IPsec implementation? Are there
  things that should be implemented but we don't have it?
