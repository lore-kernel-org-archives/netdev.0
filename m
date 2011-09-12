From: Paul Stewart <pstew@chromium.org>
Subject: Re: [PATCH] ipv6: Create module parameter for use_tempaddr
Date: Mon, 12 Sep 2011 14:21:50 -0700
Message-ID: <CAMcMvsin5dLNCHzv=meQu4SuCSanNVBVpBAAQg3HrKYDguhO2g@mail.gmail.com>
References: <20110901062754.5D1642043D@glenhelen.mtv.corp.google.com>
	<CAMcMvsgZ8t=dh5G=QuFKODCyrBX56nveztq=0QBwaUfO46KL9Q@mail.gmail.com>
	<CAMcMvsja6hmHj3-+vCYLnXXBbGznK9EJbx+mkBgT8gR6iwRoWg@mail.gmail.com>
	<4E6E62D1.8010108@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:23173 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754442Ab1ILVVy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2011 17:21:54 -0400
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p8CLLqq6004707
	for <netdev@vger.kernel.org>; Mon, 12 Sep 2011 14:21:53 -0700
Received: from ywb3 (ywb3.prod.google.com [10.192.2.3])
	by wpaz33.hot.corp.google.com with ESMTP id p8CLLVpd007692
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 12 Sep 2011 14:21:51 -0700
Received: by ywb3 with SMTP id 3so1973387ywb.21
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2011 14:21:51 -0700 (PDT)
In-Reply-To: <4E6E62D1.8010108@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 12, 2011 at 12:51 PM, Brian Haley <brian.haley@hp.com> wrot=
e:
> On 09/12/2011 12:37 PM, Paul Stewart wrote:
>> Hello, folks. =A0I've been trying to upstream (or open a discussion =
on)
>> adding a module parameter to enable IPv6 address privacy as a module
>> parameter. =A0The author listed for if_inet6.c is not a bouncing ema=
il
>> address. =A0Does anyone else have a suggestion for where to get this
>> change vetted? =A0I'm now CC'ing the author and reviewer of the last
>> module parameter change for ipv6.
>
> I think David would just tell you to be patient, your patch is listed=
 in
> patchwork, http://patchwork.ozlabs.org/project/netdev/list/ , and git=
=2Ekernel.org
> is still down...

Thanks Brian.  At least I can guess now that I'm sending mail to the
right list. :-)

--
Paul
>
>>>> =A0static int disable_ipv6_mod =3D 0;
>>>> @@ -89,6 +92,11 @@ MODULE_PARM_DESC(disable_ipv6, "Disable IPv6 on=
 all interfaces");
>>>> =A0module_param_named(autoconf, ipv6_defaults.autoconf, int, 0444)=
;
>>>> =A0MODULE_PARM_DESC(autoconf, "Enable IPv6 address autoconfigurati=
on on all interfaces");
>>>>
>>>> +#ifdef CONFIG_IPV6_PRIVACY
>>>> +module_param_named(use_tempaddr, ipv6_defaults.use_tempaddr, int,=
 0444);
>>>> +MODULE_PARM_DESC(use_tempaddr, "Enable IPv6 address privacy for a=
utoconfiguration by default");
>>>> +#endif
>
> I don't know if you want this under an #ifdef, since that could fail =
a module
> load on certain kernel builds - people might want to put the same ent=
ry in a
> conf file whether the kernel supports it or not (if it's accepted).
>
> And you failed to update Documentation/networking/ipv6.txt
>
> -Brian
>
