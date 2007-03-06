From: "Andy Gospodarek" <andy@greyhouse.net>
Subject: Re: [PATCH 3/3] bonding: Improve IGMP join processing
Date: Tue, 6 Mar 2007 15:44:27 -0500
Message-ID: <bdfc5d6e0703061244q2bc9403cs7c6321136fd8e4e0@mail.gmail.com>
References: <200703010103.l2113b22030905@death.nxdomain.ibm.com>
	 <20070301164918.GA3199@gospo.rdu.redhat.com>
	 <200703011705.l21H5Q22005750@death.nxdomain.ibm.com>
	 <45E7289F.60406@hp.com> <20070301194305.GB3199@gospo.rdu.redhat.com>
	 <45EDC730.40007@hp.com> <22603.1173213557@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Brian Haley" <brian.haley@hp.com>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
To: "Jay Vosburgh" <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.232]:55975 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876AbXCFUo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 15:44:29 -0500
Received: by wr-out-0506.google.com with SMTP id 58so3015820wri
        for <netdev@vger.kernel.org>; Tue, 06 Mar 2007 12:44:28 -0800 (PST)
In-Reply-To: <22603.1173213557@death>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/6/07, Jay Vosburgh <fubar@us.ibm.com> wrote:
> Brian Haley <brian.haley@hp.com> wrote:
>
> >Andy Gospodarek wrote:
> >> If we are easily able to differentiate between the multicast addresses
> >> in the mc_list as to which are for ipv4 and which are for ipv6 then it
> >> would be easy to call-out to something in the ipv6 mcast code when
> >> needed instead of always calling out to ipv4 code.
> >
> >I've been unable to figure out exactly what you're referring to in the
> >code (bond_main.c), it seems to failover all multicast addresses,
> >regardless of what address family they are.  I might have missed something
> >in 4K lines of code though?
>
>         I believe Andy is talking about bond_resend_igmp_join_requests
> being only effective for IGMP v4 and not IGMP v6.  The reason being that
> there is (a) no discrimination between v4 and v6 multicast addresses,
> and (b) for the v6 case, there's no "rejoin" type function as was
> created for IPv4 with the patch.
>

/me nods
