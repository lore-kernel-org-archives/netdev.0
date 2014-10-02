From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 1/2] iproute2: Add support for IPv6 VTI tunnels to
 ip6tunnel
Date: Thu, 2 Oct 2014 10:48:20 +0200
Message-ID: <20141002084820.GF6390@secunet.com>
References: <20140926071056.GB6390@secunet.com>
 <20141002084109.GI1844@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	<netdev@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:41149 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751912AbaJBIs1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2014 04:48:27 -0400
Content-Disposition: inline
In-Reply-To: <20141002084109.GI1844@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 02, 2014 at 10:41:09AM +0200, Jiri Pirko wrote:
> Fri, Sep 26, 2014 at 09:10:56AM CEST, steffen.klassert@secunet.com wrote:
> >
> >@@ -459,11 +462,14 @@ static int do_add(int cmd, int argc, char **argv)
> > 	switch (p.proto) {
> > 	case IPPROTO_IPIP:
> > 	case IPPROTO_IPV6:
> >+	if (p.i_flags != VTI_ISVTI)
> >+		return tnl_add_ioctl(cmd, "ip6_vti0", p.name, &p);
>                                               ^ Wouldn't it be more
> 					      consistent to not to use
> 					      the underscore? 

The ipv4 version of vti uses ip_vti0, so I tried to be consistent
with that. 
