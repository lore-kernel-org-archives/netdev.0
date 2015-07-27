From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/2] iproute2: Add support for IPv6 VTI tunnels to
 ip6tunnel
Date: Mon, 27 Jul 2015 14:38:45 -0700
Message-ID: <20150727143845.7f5c3a26@urahara>
References: <20140926071056.GB6390@secunet.com>
	<20141002084109.GI1844@nanopsycho.orion>
	<20141002084820.GF6390@secunet.com>
	<20141002091140.GA1865@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35246 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753291AbbG0Vif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 17:38:35 -0400
Received: by pabkd10 with SMTP id kd10so57610413pab.2
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 14:38:35 -0700 (PDT)
In-Reply-To: <20141002091140.GA1865@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2 Oct 2014 11:11:40 +0200
Jiri Pirko <jiri@resnulli.us> wrote:

> Thu, Oct 02, 2014 at 10:48:20AM CEST, steffen.klassert@secunet.com wrote:
> >On Thu, Oct 02, 2014 at 10:41:09AM +0200, Jiri Pirko wrote:
> >> Fri, Sep 26, 2014 at 09:10:56AM CEST, steffen.klassert@secunet.com wrote:
> >> >
> >> >@@ -459,11 +462,14 @@ static int do_add(int cmd, int argc, char **argv)
> >> > 	switch (p.proto) {
> >> > 	case IPPROTO_IPIP:
> >> > 	case IPPROTO_IPV6:
> >> >+	if (p.i_flags != VTI_ISVTI)
> >> >+		return tnl_add_ioctl(cmd, "ip6_vti0", p.name, &p);
> >>                                               ^ Wouldn't it be more
> >> 					      consistent to not to use
> >> 					      the underscore? 
> >
> >The ipv4 version of vti uses ip_vti0, so I tried to be consistent
> >with that. 
> 
> Okay, fine with me.

Sure, applied.
