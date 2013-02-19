From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: Universal tap device
Date: Tue, 19 Feb 2013 05:59:41 -0500
Message-ID: <51235B1D.1060109@mojatatu.com>
References: <20130216140132.GB1536@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arnd@arndb.de, ebiederm@xmission.com,
	stephen@networkplumber.org, eric.dumazet@gmail.com,
	davem@davemloft.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:42529 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932299Ab3BSK7y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 05:59:54 -0500
Received: by mail-ie0-f172.google.com with SMTP id c10so8344462ieb.31
        for <netdev@vger.kernel.org>; Tue, 19 Feb 2013 02:59:54 -0800 (PST)
In-Reply-To: <20130216140132.GB1536@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



I dont know what macvtap is, but what dont you like about redirecting or 
mirroring packets to tap? Or packet socket?
I think tap has become a christmas tree lately compared to its humble 
beginnings, and its performance is questionable - but it should still
work for what you need.

cheers,
jamal

On 13-02-16 09:01 AM, Jiri Pirko wrote:
> Hi all.
>
> Looking at macvtap and thinking about the tap solutions in general, I
> think it would be handly to have some universal tap device.
>
> This could use rx_handler to hook onto any netdev and provide chardev
> tap-like iface to it. Using that, one can just hook onto macvlan device
> and macvtap would not be needed.
>
> This would allow other scenarios like vxlan-tap, vlan-tap, bond-tap or
> whatever.
>
> Does this idea seem to be reasonable?
>
> Thanks
>
> Jiri
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
