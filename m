From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] net: add netnotifier event for upper device
 change
Date: Sun, 26 May 2013 09:10:39 +0200
Message-ID: <20130526071039.GA1560@minipsycho.orion>
References: <1369491130-7412-1-git-send-email-jiri@resnulli.us>
 <20130525.231413.1228840457158928295.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, edumazet@google.com,
	alexander.h.duyck@intel.com, xiyou.wangcong@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f176.google.com ([209.85.215.176]:65048 "EHLO
	mail-ea0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757765Ab3EZHKo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 May 2013 03:10:44 -0400
Received: by mail-ea0-f176.google.com with SMTP id k11so3445525eaj.35
        for <netdev@vger.kernel.org>; Sun, 26 May 2013 00:10:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130525.231413.1228840457158928295.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, May 26, 2013 at 08:14:13AM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Sat, 25 May 2013 16:12:10 +0200
>
>> Now when upper device is changed, event is not propagated via RT Netlink
>> to userspace. Userspace might never now about the change. Fix this by
>> adding upper-device-change notifier event.
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>
>Looks good, applied, thanks Jiri.
>
>If someone is looking for a useful project, switching networking over to
>a more typed notifier system would be a worthwhile improvement.
>
>It's hard to right now to communicate what changed beyond "action X
>happened to this object, you have to check to see exactly how it
>changed"

Hmm. Do you have something particular in mind? My first thought was
passing some union instead of NETDEV_* numbers.

>
>This came up recently with the IFF_NOARP stuff.

Can you point me to the discussion?

Thanks

Jiri
