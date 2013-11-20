From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC v2 1/2] ipv6 addrconf: extend ifa_flags to
 u32
Date: Wed, 20 Nov 2013 15:08:29 +0100
Message-ID: <20131120140829.GA15778@minipsycho.orion>
References: <1384857809-6573-1-git-send-email-jiri@resnulli.us>
 <1384857809-6573-2-git-send-email-jiri@resnulli.us>
 <20131119.161653.1620911822393300977.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, thaller@redhat.com,
	stephen@networkplumber.org, hannes@stressinduktion.org,
	vyasevich@gmail.com, dcbw@redhat.com, David.Laight@ACULAB.COM
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f182.google.com ([209.85.215.182]:54111 "EHLO
	mail-ea0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133Ab3KTOIg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 09:08:36 -0500
Received: by mail-ea0-f182.google.com with SMTP id o10so4923086eaj.27
        for <netdev@vger.kernel.org>; Wed, 20 Nov 2013 06:08:32 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131119.161653.1620911822393300977.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Nov 19, 2013 at 10:16:53PM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Tue, 19 Nov 2013 11:43:28 +0100
>
>> There is no more space in u8 ifa_flags. So do what davem suffested and
>> add another netlink attr called IFA_FLAGS for carry more flags.
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> Signed-off-by: Thomas Haller <thaller@redhat.com>
>> ---
>> v1->v2:
>> - reordered struct inet6_ifaddr as suggested by David Laight
>> - changed flags type to u32 on couple of places as suggested by Thomas Haller
>> - changed output of if6_seq_show as suggested by Thomas Haller
>
>This looks fine, but I would suggest to extend this to all addressing
>types using ifm->ifa_flags.  It is not such a big deal, there are only
>3 or 4.

Okay - I will do that.

>
>DecNET, ipv4, ipv6, and lastly phonet (which just reports "permanent"
>flag on get/dump).
>
>That way tools like iproute2 can just generically provide and
>interpret IFA_FLAGS attribute unconditionally.

Well the check and ->ifa_flags fallback needs to be in iproute2 anyway
in order to maintain compatibility with older kernels.

Thanks for review!

Jiri
