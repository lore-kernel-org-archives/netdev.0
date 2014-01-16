From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net] ipv6: simplify detection of first operational
 link-local address on interface
Date: Thu, 16 Jan 2014 22:47:31 +0100
Message-ID: <20140116214731.GA28284@minipsycho.orion>
References: <20140116135323.GA7961@minipsycho.orion>
 <20140116191304.GC17529@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, fbl@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f45.google.com ([74.125.83.45]:55259 "EHLO
	mail-ee0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751038AbaAPVre (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 16:47:34 -0500
Received: by mail-ee0-f45.google.com with SMTP id b15so1690586eek.32
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 13:47:33 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20140116191304.GC17529@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jan 16, 2014 at 08:13:04PM CET, hannes@stressinduktion.org wrote:
>In commit 1ec047eb4751e3 ("ipv6: introduce per-interface counter for
>dad-completed ipv6 addresses") I build the detection of the first
>operational link-local address much to complex. Additionally this code
>now has a race condition.
>
>Replace it with a much simpler variant, which just scans the address
>list when duplicate address detection completes, to check if this is
>the first valid link local address and send RS and MLD reports then.
>
>Fixes: 1ec047eb4751e3 ("ipv6: introduce per-interface counter for dad-completed ipv6 addresses")
>Reported-by: Jiri Pirko <jiri@resnulli.us>
>Cc: Flavio Leitner <fbl@redhat.com>
>Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Acked-by: Jiri Pirko <jiri@resnulli.us>
