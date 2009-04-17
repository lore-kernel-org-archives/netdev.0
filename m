From: Christoph Lameter <cl@linux.com>
Subject: Re: PATCH: Multicast: Filter multicast traffic per socket mc_list
Date: Fri, 17 Apr 2009 09:56:04 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904170952050.11877@qirst.com>
References: <alpine.DEB.1.10.0904161136220.15629@qirst.com> <20090416174422.GB28978@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904161508520.15835@qirst.com> <20090416.151641.220683663.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org,
	vladislav.yasevich@hp.com, dlstevens@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:60012 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756454AbZDQODY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 10:03:24 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 4F64582C381
	for <netdev@vger.kernel.org>; Fri, 17 Apr 2009 10:13:22 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id uKbpbdbZ0Kis for <netdev@vger.kernel.org>;
	Fri, 17 Apr 2009 10:13:22 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 2F83A82C386
	for <netdev@vger.kernel.org>; Fri, 17 Apr 2009 10:13:16 -0400 (EDT)
In-Reply-To: <20090416.151641.220683663.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 16 Apr 2009, David Miller wrote:

> No Christoph, do this right.
>
	> Linux by default will behave the way it has for 15+ years.  And if an
> application wants new behavior, you have to ask for it.
>
> End of story.

This is not right. All other OSes filter multicast traffic according to
the multicast groups subscribed too (and that includes the evil one).
There is no requirement of asking for "new" behavior. Why should multicast
applications have to add special code to request something that comes by
default on other platforms?

The old behavior does not seem to be usable anyways and its certainly
looks buggy if multicast packets are duplicated by the kernel and sent to
applications that never have asked for it. And OS should do the sane thing
by default and not only if someone asks for it.


