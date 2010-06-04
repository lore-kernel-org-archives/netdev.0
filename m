From: Ferenc Wagner <wferi@niif.hu>
Subject: Re: Is CONFIG_IP_VS_IPV6 still/really dangerous?
Date: Sat, 05 Jun 2010 00:21:58 +0200
Message-ID: <87aarah20p.fsf@tac.ki.iif.hu>
References: <87631y3nr3.fsf@tac.ki.iif.hu>
	<AANLkTikQPaHYuOOAiJtIft9NnOZ2S1LXTVMi_BLD8gau@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, robert.gallagher@heanet.ie,
	Julius Volz <juliusv@google.com>
To: lvs-users@linuxvirtualserver.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tac.ki.iif.hu ([193.6.222.43]:42843 "EHLO tac.ki.iif.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757146Ab0FDWWE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jun 2010 18:22:04 -0400
In-Reply-To: <AANLkTikQPaHYuOOAiJtIft9NnOZ2S1LXTVMi_BLD8gau@mail.gmail.com>
	(Julius Volz's message of "Fri, 4 Jun 2010 16:14:37 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julius Volz <juliusv@google.com> writes:

> On Fri, Jun 4, 2010 at 3:56 PM, Ferenc Wagner <wferi@niif.hu> wrote:
>
>> In commit fab0de02fb0da83b90cec7fce4294747d86d5c6f CONFIG_IP_VS_IPV6=
 is
>> described as:
>>
>> =C2=A0 =C2=A0Add IPv6 support to IPVS. This is incomplete and might =
be dangerous.
>>
>> I agree its implementation is incomplete. =C2=A0But I wonder if it's=
 really
>> dangerous in the sense that generic distribution kernels shouldn't
>> enable it, because it can break unrelated (eg. IPv4 IPVS) functional=
ity.
>>
>> What does that warning mean today? =C2=A0Isn't it out of date?
>
> I wrote the IPv6 support back in the day, but never used it
> large-scale. Rob Gallagher from HEAnet was doing some bigger
> experiments with it, but I'm not sure how far it went. CCing him.
>
> There are probably some other people out there that have tested it
> extensively. Maybe try the lvs-users and lvs-devel mailing lists?

Sounds like a good idea!  So:

Dear lvs-users,

did you experience any breakage as a result of switching on
CONFIG_IP_VS_IPV6?  I mean apart from it having incomplete
functionality.  The gist of the question is whether this option
is suitable for generic distro kernels or not, cf. above.
--=20
Thanks for your time,
=46eri.
