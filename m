From: Christoph Lameter <cl@linux.com>
Subject: Re: PATCH: Multicast: Filter multicast traffic per socket mc_list
Date: Mon, 20 Apr 2009 14:10:12 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904201337020.3361@qirst.com>
References: <alpine.DEB.1.10.0904170952050.11877@qirst.com> <49E8A240.8050404@us.ibm.com> <alpine.DEB.1.10.0904171158220.13734@qirst.com> <20090417.152412.96128121.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: niv@us.ibm.com, nhorman@tuxdriver.com, netdev@vger.kernel.org,
	vladislav.yasevich@hp.com, dlstevens@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:32824 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752423AbZDTSSK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 14:18:10 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 4BE5E82C423
	for <netdev@vger.kernel.org>; Mon, 20 Apr 2009 14:28:27 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id SiqsuueMx2tA for <netdev@vger.kernel.org>;
	Mon, 20 Apr 2009 14:28:27 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 82AFE82C44C
	for <netdev@vger.kernel.org>; Mon, 20 Apr 2009 14:28:22 -0400 (EDT)
In-Reply-To: <20090417.152412.96128121.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 17 Apr 2009, David Miller wrote:

> And the fact is, WE DID MEAN to do things this way.

I fully agree. We meant to do this.

> As David Stevens explained, the original creator of multicasting, the
> original BSD code, and the RFCs, INTENDED this behavior from the very
> beginning.
>
> You want to ignore all of this, as if none of it matters and that what
> you want to achieve is so much more important.

I am not ignoring it. It seems just that other OSes have moved from this
and we are one of the last holdouts. Its not only Solaris but also BSD and
Windoze. Best to have a solution that is consistent across multiple OSes.


