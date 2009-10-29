From: "Neulinger, Nathan" <nneul@mst.edu>
Subject: RE: How to use gretap with bridge?
Date: Thu, 29 Oct 2009 15:22:19 -0500
Message-ID: <846C5B546E47494CBBD796CA8CA1617EA3B431@MST-VMAIL1.srv.mst.edu>
References: <846C5B546E47494CBBD796CA8CA1617EA3B414@MST-VMAIL1.srv.mst.edu><20091029170631.GA29405@gondor.apana.org.au><846C5B546E47494CBBD796CA8CA1617EA3B428@MST-VMAIL1.srv.mst.edu> <20091029130036.1e61f415@nehalam>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxnip01-rolla-out.um.umsystem.edu ([209.106.229.55]:40051 "EHLO
	mxnip01-rolla-out.um.umsystem.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754848AbZJ2UWQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2009 16:22:16 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20091029130036.1e61f415@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was referring to the local IP in the "ip link add ... remote x.z.z.z
local y.z.z.z" command specifying the endpoints of the tunnel. It lets
it be added to the bridge if y is even, but not if y is odd. Why should
it care what the IP of the tunnel endpoints are?

-- Nathan

------------------------------------------------------------
Nathan Neulinger                       nneul@mst.edu
Missouri S&T Information Technology    (573) 612-1412
System Administrator - Principal       KD0DMH


> -----Original Message-----
> From: Stephen Hemminger [mailto:shemminger@vyatta.com]
> Sent: Thursday, October 29, 2009 3:01 PM
> To: Neulinger, Nathan
> Cc: netdev@vger.kernel.org
> Subject: Re: How to use gretap with bridge?
> 
> On Thu, 29 Oct 2009 14:01:31 -0500
> "Neulinger, Nathan" <nneul@mst.edu> wrote:
> 
> > Further testing - if the leading octet of the 'local' address is
> even,
> > it allows it to be added to bridge, if it's odd, it won't.
> >
> > Any ideas?
> >
> 
> If leading octet of MAC address is odd, then bridge thinks it
> is not a valid ethernet for bridging because it is a multicast
> address.
> 
> 
> --
