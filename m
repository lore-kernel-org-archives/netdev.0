From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC v2 2/2] ipv6 addrconf: introduce
 IFA_F_MANAGETEMPADDR to tell kernel to manage temporary addresses
Date: Wed, 20 Nov 2013 17:18:38 +0100
Message-ID: <20131120161838.GB15778@minipsycho.orion>
References: <1384857809-6573-1-git-send-email-jiri@resnulli.us>
 <1384857809-6573-3-git-send-email-jiri@resnulli.us>
 <20131120160543.GV16541@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	thaller@redhat.com, stephen@networkplumber.org,
	vyasevich@gmail.com, dcbw@redhat.com, David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f171.google.com ([209.85.215.171]:47831 "EHLO
	mail-ea0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754355Ab3KTQSl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 11:18:41 -0500
Received: by mail-ea0-f171.google.com with SMTP id h10so4075529eak.30
        for <netdev@vger.kernel.org>; Wed, 20 Nov 2013 08:18:40 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131120160543.GV16541@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Nov 20, 2013 at 05:05:43PM CET, hannes@stressinduktion.org wrote:
>On Tue, Nov 19, 2013 at 11:43:29AM +0100, Jiri Pirko wrote:
>> Creating an address with this flag set will result in kernel taking care
>> of temporary addresses in the same way as if the address was created by
>> kernel itself (after RA receive). This allows userspace applications
>> implementing the autoconfiguration (NetworkManager for example) to
>> implement ipv6 addresses privacy.
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> Signed-off-by: Thomas Haller <thaller@redhat.com>
>
>The patch looks good.
>
>Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>
>The _bh conversion seems not to be strictly necessary, no?
>ipv6_create_tempaddr is always called with bh disabled.

It is needed. Found out using lock debug config option.

>
>Thanks,
>
>  Hannes
>
