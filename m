From: Julius Volz <juliusv@google.com>
Subject: Re: Is CONFIG_IP_VS_IPV6 still/really dangerous?
Date: Fri, 4 Jun 2010 16:14:37 +0200
Message-ID: <AANLkTikQPaHYuOOAiJtIft9NnOZ2S1LXTVMi_BLD8gau@mail.gmail.com>
References: <87631y3nr3.fsf@tac.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, robert.gallagher@heanet.ie
To: Ferenc Wagner <wferi@niif.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:49962 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932293Ab0FDOOm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jun 2010 10:14:42 -0400
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id o54EEdhi022298
	for <netdev@vger.kernel.org>; Fri, 4 Jun 2010 07:14:39 -0700
Received: from gyf1 (gyf1.prod.google.com [10.243.50.65])
	by kpbe12.cbf.corp.google.com with ESMTP id o54EEWrI021943
	for <netdev@vger.kernel.org>; Fri, 4 Jun 2010 07:14:38 -0700
Received: by gyf1 with SMTP id 1so1000529gyf.21
        for <netdev@vger.kernel.org>; Fri, 04 Jun 2010 07:14:38 -0700 (PDT)
In-Reply-To: <87631y3nr3.fsf@tac.ki.iif.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ferenc,

On Fri, Jun 4, 2010 at 3:56 PM, Ferenc Wagner <wferi@niif.hu> wrote:
> Hi,
>
> In commit fab0de02fb0da83b90cec7fce4294747d86d5c6f CONFIG_IP_VS_IPV6 =
is
> described as:
>
> =A0 =A0Add IPv6 support to IPVS. This is incomplete and might be dang=
erous.
>
> I agree its implementation is incomplete. =A0But I wonder if it's rea=
lly
> dangerous in the sense that generic distribution kernels shouldn't
> enable it, because it can break unrelated (eg. IPv4 IPVS) functionali=
ty.
>
> What does that warning mean today? =A0Isn't it out of date?

I wrote the IPv6 support back in the day, but never used it
large-scale. Rob Gallagher from HEAnet was doing some bigger
experiments with it, but I'm not sure how far it went. CCing him.

There are probably some other people out there that have tested it
extensively. Maybe try the lvs-users and lvs-devel mailing lists?

http://www.linuxvirtualserver.org/mailing.html

Julius

--=20
Julius Volz - Site Reliability Engineer
Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
