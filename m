From: Christoph Lameter <cl@linux.com>
Subject: Re: PATCH: Multicast: Filter multicast traffic per socket mc_list
Date: Fri, 17 Apr 2009 12:02:19 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904171158220.13734@qirst.com>
References: <alpine.DEB.1.10.0904161136220.15629@qirst.com> <20090416174422.GB28978@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904161508520.15835@qirst.com> <20090416.151641.220683663.davem@davemloft.net> <alpine.DEB.1.10.0904170952050.11877@qirst.com>
 <49E8A240.8050404@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, nhorman@tuxdriver.com,
	netdev@vger.kernel.org, vladislav.yasevich@hp.com,
	dlstevens@us.ibm.com
To: Nivedita Singhvi <niv@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:49129 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757093AbZDQQJh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 12:09:37 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 637DE82C3AA
	for <netdev@vger.kernel.org>; Fri, 17 Apr 2009 12:19:36 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id g0Zpl1ao3hr4 for <netdev@vger.kernel.org>;
	Fri, 17 Apr 2009 12:19:36 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id AC90182C3B3
	for <netdev@vger.kernel.org>; Fri, 17 Apr 2009 12:19:31 -0400 (EDT)
In-Reply-To: <49E8A240.8050404@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 17 Apr 2009, Nivedita Singhvi wrote:

> I need the current behaviour to not change, as it would
> break some people I support.  DaveM is making the right
> decision here, and I fully support this.

People or applications? There are applications that only run on Linux and
fail on other OS? How does this work? Special casing depending on the OS
running?

> Ideally, you could tweak OS environment configuration
> setting, if you don't want per socket. But it cannot
> be the default.

Would you support an additional OS config variable that would set the
default for socket operations? Then we could have a per socket option that
would allow overriding the OS config variable?
