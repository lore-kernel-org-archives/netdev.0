From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next V2] bond: have random dev address by default
 instead of zeroes
Date: Fri, 25 Jan 2013 21:00:28 +0100
Message-ID: <20130125200028.GD1821@minipsycho.orion>
References: <542237717.4200599.1359136587903.JavaMail.root@redhat.com>
 <22106.1359138692@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Simerda <psimerda@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, andy@greyhouse.net,
	stephen@networkplumber.org, dcbw@redhat.com
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f171.google.com ([209.85.215.171]:50031 "EHLO
	mail-ea0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751108Ab3AYUAc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2013 15:00:32 -0500
Received: by mail-ea0-f171.google.com with SMTP id c13so330822eaa.16
        for <netdev@vger.kernel.org>; Fri, 25 Jan 2013 12:00:31 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <22106.1359138692@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jan 25, 2013 at 07:31:32PM CET, fubar@us.ibm.com wrote:
>Pavel Simerda <psimerda@redhat.com> wrote:
>
>>----- Original Message -----
>>> From: "Jay Vosburgh" <fubar@us.ibm.com>
>>> but I don't think it should be changed.
>>
>>Just a short question. Is there any reason for bonding interfaces to
>>behave differently from bridging interfaces in this respect?
>
>	To clarify, what I don't think should change is that a manually
>set MAC on the bonding master should override the automatic copy of the
>first slave's MAC to the bonding master.  The fail_over_mac active and
>follow settings are an exception to this, but those are special cases
>for unusual network hardware.
>
>	As for the random MAC vs. zero MAC, I've always thought that the
>all zero MAC was a clear indicator that the device (the bonding master
>in this case) was not in a usable state (in the sense that it could not
>send or receive actual traffic).  It's not a really big deal, though, so
>if the trend these days is for everything to have a MAC all the time,
>that's fine, as long as doing so doesn't break anything.
>
>	I think the patch under discussion should be fine with the
>addition of the last notifier call previously discussed.  Some
>documentation updates would be nice, too.

Will do :)

>
>	-J
>
>---
>	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
