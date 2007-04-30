From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH][XFRM] export SPD info
Date: Mon, 30 Apr 2007 08:04:36 -0400
Message-ID: <1177934676.7027.11.camel@localhost>
References: <1177681421.4059.2.camel@localhost> <463200CC.6010207@trash.net>
	 <1177684168.4059.38.camel@localhost>
	 <20070428.211936.35015201.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.229]:1636 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031544AbXD3MEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2007 08:04:40 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1509261wxd
        for <netdev@vger.kernel.org>; Mon, 30 Apr 2007 05:04:39 -0700 (PDT)
In-Reply-To: <20070428.211936.35015201.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2007-28-04 at 21:19 -0700, David Miller wrote:

> I think filtering in the kernel makes sense when the kernel
> is in a unique place to make the algorithmic complexity of the
> filtering minimal.  The TCP socket dumping is a good example
> of that.
> 
> For things like this I think it's really unnecessary.
> 

Ok, maybe it was a little overkill - and i forgot about the tcpdiag
code, so there is already a sample that can be referenced.. 

> Figure out what the basic information is and just provide it every
> time.  You have a full release cycle to work out what that is, and if
> we miss anything, afterwards we can still extend with attributes.

Will do sometime this week - I will also do the same for the earlier SAD
patch.

cheers,
jamal

