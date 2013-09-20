From: Vincent Li <vincent.mc.li@gmail.com>
Subject: Re: add ip to interface as primary ip address, not secondary ip when
 there is alreadly primary ip?
Date: Thu, 19 Sep 2013 20:53:48 -0700
Message-ID: <CAK3+h2xdZFSQFGm9W+HDP3nOsAhgrz1A=9MNtGP9bRbBXb7OJQ@mail.gmail.com>
References: <CAK3+h2zPYYLaVs-WhHFaDhOsnLBB7m8vDvkTj5a16FUJ02i4KA@mail.gmail.com>
	<l1as5j$7cs$1@ger.gmane.org>
	<CAK3+h2yWjswp6qrToMPbrQyuyCKkh5Yuuo6TeX8VhGQCGpCecw@mail.gmail.com>
	<l1gbs4$da2$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:54534 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753135Ab3ITDxt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Sep 2013 23:53:49 -0400
Received: by mail-ob0-f181.google.com with SMTP id gq1so10660412obb.26
        for <netdev@vger.kernel.org>; Thu, 19 Sep 2013 20:53:49 -0700 (PDT)
In-Reply-To: <l1gbs4$da2$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

yes, I found them too, they are for 'ip addr show' or 'ip addr list'
though, not for 'ip addr add' unless  I am missing something obvious.
care to clarify further ?

Vincent

On Thu, Sep 19, 2013 at 7:28 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Thu, 19 Sep 2013 at 16:54 GMT, Vincent Li <vincent.mc.li@gmail.com> wrote:
>> thanks for the pointer
>>
>> 'ip addr' indeed has flag IFA_F_SECONDARY for this, but it is not
>> available for 'ip addr add', so I made a simple patch for iproute2
>> ip/ipaddress.c as below:
>
> % git grep secondary ip/ipaddress.c
> ip/ipaddress.c: fprintf(stderr, "FLAG  := [ permanent | dynamic |
> secondary | primary |\n");
> ip/ipaddress.c:                 fprintf(fp, "secondary ");
> ip/ipaddress.c:static int print_addrinfo_secondary(const struct
> sockaddr_nl *who,
> ip/ipaddress.c:                         .filter =
> print_addrinfo_secondary,
> ip/ipaddress.c:         } else if (strcmp(*argv, "secondary") == 0 ||
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
