From: Paul Moore <paul.moore@hp.com>
Subject: [RFC PATCH v2 0/2] Labeled networking core stack changes for 2.6.25
Date: Mon, 07 Jan 2008 12:47:35 -0500
Message-ID: <20080107173829.13488.47471.stgit@flek.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:2235 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755798AbYAGRrm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2008 12:47:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Take #2 ...

Once again, two patches.  The first should be familiar as it is the same patch
as before with feedback taken into account.  The second patch is most likely
new to the netdev crowd as it consists of the SELinux changes necessary to
implement the network ingress/egress controls I talked about last week after
the previous approach was rejected.

You will note that the ingress/egress controls are now completely contained
within the LSM/SELinux code using the skb->dst->xfrm approach mentioned last
Friday.  For those of you who want/need more context when looking at the
second patch, you can find the rest of the patches here:

 * git://git.infradead.org/users/pcmoore/lblnet-2.6_testing 
 * http://git.infradead.org/?p=users/pcmoore/lblnet-2.6_testing

Just as before, I'm posting these patches here for review and hopefully an
'Acked-by', not inclusion into net-2.6.25.  If these patches are acceptable
then they will pushed upstream with the rest of the changes when 2.6.25 is
ready.

Thanks.

-- 
paul moore
linux security @ hp
