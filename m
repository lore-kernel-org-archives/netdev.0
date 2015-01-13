From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: why are IPv6 addresses removed on link down
Date: Tue, 13 Jan 2015 18:05:19 +0100
Message-ID: <54B5504F.2020200@6wind.com>
References: <54B4A7E4.7030301@gmail.com> <20150112231021.316648e3@urahara>		 <1421145346.13626.12.camel@redhat.com> <54B50873.4090907@miraclelinux.com>		 <54B50C71.7090007@miraclelinux.com> <1421152613.13626.24.camel@redhat.com>	 <54B53187.7080306@gmail.com> <1421161230.13626.30.camel@stressinduktion.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:51883 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751253AbbAMRFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 12:05:23 -0500
Received: by mail-lb0-f172.google.com with SMTP id z12so3678459lbi.3
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 09:05:21 -0800 (PST)
In-Reply-To: <1421161230.13626.30.camel@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 13/01/2015 16:00, Hannes Frederic Sowa a =C3=A9crit :
[snip]
>
> This was already discussed several times here, e.g. one patch I just
> found:
>
> http://lists.openwall.net/netdev/2011/01/24/8
> and
> http://patchwork.ozlabs.org/patch/17558/
>
> Albeit I hate sysctls for things like this, it might I tend to find i=
t
> acceptable because it solves a problem which happened to lots of peop=
le.
> And I don't like the current behavior neither.
>
> I think this can work, but we should follow up all the old discussion=
s
> to not introduce any kind of new undesired behavior this time.
If I remember well, one of the problem was that it was not possible any=
more to
unload the IPv6 module after the patches. But since commit 8ce440610357=
 ("ipv6:
do not allow ipv6 module to be removed"), it's not possible anymore.
