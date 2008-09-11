From: "Rami Rosen" <roszenrami@gmail.com>
Subject: Re: ipv6 neighbour code keeps interfaces held
Date: Thu, 11 Sep 2008 10:11:48 +0300
Message-ID: <b25312890809110011j4f8827aam23175e2e650b0d4b@mail.gmail.com>
References: <1221081539.3804.33.camel@johannes.berg>
	 <20080910.164009.92497081.davem@davemloft.net>
	 <1221091053.3804.53.camel@johannes.berg>
	 <20080910.170006.65586950.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.182]:2627 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751491AbYIKHLt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 03:11:49 -0400
Received: by py-out-1112.google.com with SMTP id p76so191741pyb.10
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 00:11:48 -0700 (PDT)
In-Reply-To: <20080910.170006.65586950.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>That's how often garbage collection runs on ICMP6 routes.

And which, BTW, can be configured through:
 /proc/sys/net/ipv6/route/gc_interval

Regards,
Rami Rosen


On Thu, Sep 11, 2008 at 3:00 AM, David Miller <davem@davemloft.net> wrote:
> From: Johannes Berg <johannes@sipsolutions.net>
> Date: Thu, 11 Sep 2008 01:57:33 +0200
>
>> And then they time out after 30 seconds? I see the message exactly three
>> times and then it gets removed.
>
> That's how often garbage collection runs on ICMP6 routes.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
