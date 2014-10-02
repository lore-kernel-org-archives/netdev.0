From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH 1/2] iproute2: Add support for IPv6 VTI tunnels to
 ip6tunnel
Date: Thu, 2 Oct 2014 11:11:40 +0200
Message-ID: <20141002091140.GA1865@nanopsycho.orion>
References: <20140926071056.GB6390@secunet.com>
 <20141002084109.GI1844@nanopsycho.orion>
 <20141002084820.GF6390@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:34671 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751282AbaJBJLn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 05:11:43 -0400
Received: by mail-wi0-f176.google.com with SMTP id hi2so3239925wib.9
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2014 02:11:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20141002084820.GF6390@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Oct 02, 2014 at 10:48:20AM CEST, steffen.klassert@secunet.com wrote:
>On Thu, Oct 02, 2014 at 10:41:09AM +0200, Jiri Pirko wrote:
>> Fri, Sep 26, 2014 at 09:10:56AM CEST, steffen.klassert@secunet.com wrote:
>> >
>> >@@ -459,11 +462,14 @@ static int do_add(int cmd, int argc, char **argv)
>> > 	switch (p.proto) {
>> > 	case IPPROTO_IPIP:
>> > 	case IPPROTO_IPV6:
>> >+	if (p.i_flags != VTI_ISVTI)
>> >+		return tnl_add_ioctl(cmd, "ip6_vti0", p.name, &p);
>>                                               ^ Wouldn't it be more
>> 					      consistent to not to use
>> 					      the underscore? 
>
>The ipv4 version of vti uses ip_vti0, so I tried to be consistent
>with that. 

Okay, fine with me.
