From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: How to use gretap with bridge?
Date: Thu, 29 Oct 2009 15:12:22 -0700
Message-ID: <20091029151222.156945ca@nehalam>
References: <846C5B546E47494CBBD796CA8CA1617EA3B414@MST-VMAIL1.srv.mst.edu>
	<20091029170631.GA29405@gondor.apana.org.au>
	<846C5B546E47494CBBD796CA8CA1617EA3B428@MST-VMAIL1.srv.mst.edu>
	<20091029130036.1e61f415@nehalam>
	<846C5B546E47494CBBD796CA8CA1617EA3B431@MST-VMAIL1.srv.mst.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "Neulinger, Nathan" <nneul@mst.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54452 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755959AbZJ2WMX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2009 18:12:23 -0400
In-Reply-To: <846C5B546E47494CBBD796CA8CA1617EA3B431@MST-VMAIL1.srv.mst.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 29 Oct 2009 15:22:19 -0500
"Neulinger, Nathan" <nneul@mst.edu> wrote:

> I was referring to the local IP in the "ip link add ... remote x.z.z.z
> local y.z.z.z" command specifying the endpoints of the tunnel. It lets
> it be added to the bridge if y is even, but not if y is odd. Why should
> it care what the IP of the tunnel endpoints are?
> 
> -- Nathan
> 

It looks like a GRE driver bug. It uses IP address for dev->dev_addr
when it really should be generating a Ethernet address when using
Ethernet wrapper mode.
