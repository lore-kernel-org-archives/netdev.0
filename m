From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] sctp/tcp: Question -- ICMPv4 length check (not)
 redundant?
Date: Wed, 30 Jul 2008 03:19:35 -0700 (PDT)
Message-ID: <20080730.031935.61479223.davem@davemloft.net>
References: <488E0192.9030406@hp.com>
	<20080728174432.GA15892@gerrit.erg.abdn.ac.uk>
	<488E0B73.8070701@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gerrit@erg.abdn.ac.uk, netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59857
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753097AbYG3KTf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 06:19:35 -0400
In-Reply-To: <488E0B73.8070701@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Mon, 28 Jul 2008 14:09:55 -0400

> The IPv6 checks are much different.  The MUST requirement is to provide as much
> data as possible upto IPv6 min mtu.  So, the IPv6 icmp code should probably look
> to see if min(payload_len, min_mtu) is provided.

"Be liberal in what you accept..." -Jon Postel

Also, do you know any case where 576 bytes won't provide enough
quoted packet bytes? :-)
