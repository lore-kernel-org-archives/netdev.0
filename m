From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: How to use gretap with bridge?
Date: Thu, 29 Oct 2009 13:00:36 -0700
Message-ID: <20091029130036.1e61f415@nehalam>
References: <846C5B546E47494CBBD796CA8CA1617EA3B414@MST-VMAIL1.srv.mst.edu>
	<20091029170631.GA29405@gondor.apana.org.au>
	<846C5B546E47494CBBD796CA8CA1617EA3B428@MST-VMAIL1.srv.mst.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "Neulinger, Nathan" <nneul@mst.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48123 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754164AbZJ2UAk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2009 16:00:40 -0400
In-Reply-To: <846C5B546E47494CBBD796CA8CA1617EA3B428@MST-VMAIL1.srv.mst.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 29 Oct 2009 14:01:31 -0500
"Neulinger, Nathan" <nneul@mst.edu> wrote:

> Further testing - if the leading octet of the 'local' address is even,
> it allows it to be added to bridge, if it's odd, it won't.
> 
> Any ideas?
> 

If leading octet of MAC address is odd, then bridge thinks it
is not a valid ethernet for bridging because it is a multicast
address.


-- 
