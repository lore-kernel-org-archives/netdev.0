From: =?UTF-8?B?UGF2ZWwgxaBpbWVyZGE=?= <pavlix@pavlix.net>
Subject: Re: [PATCH 2/7] turn Makefile more distribution friendly
Date: Tue, 21 Apr 2015 17:32:32 +0200
Message-ID: <55366D90.8070904@pavlix.net>
References: <1428933661-8193-2-git-send-email-pavlix@pavlix.net> <20150420095515.1578733e@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, psimerda@redhat.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fox.pavlix.net ([84.246.161.104]:35622 "EHLO fox.pavlix.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932359AbbDUPeX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Apr 2015 11:34:23 -0400
In-Reply-To: <20150420095515.1578733e@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/20/2015 06:55 PM, Stephen Hemminger wrote:
> On Mon, 13 Apr 2015 16:00:56 +0200
> Pavel =C5=A0imerda <pavlix@pavlix.net> wrote:
>=20
>> From: Pavel =C5=A0imerda <psimerda@redhat.com>
>>
>> Changes:
>>
>>  * Accept directory settings from environment.
>>  * Remove redundant ROOTDIR variable.
>>  * Set KERNEL_INCLUDE default to '/usr/include'.
>>  * Use CFLAGS from environemnt.
>>
>> Note: In the long term it might be better to improve the configure
>> script to generate those parts of the Makefile in a manner similar
>> to autoconf. It might be even practical to autotoolize the package.
>>
>> Signed-off-by: Pavel =C5=A0imerda <psimerda@redhat.com>
>=20
> I will take this part.
> But don't want to start iproute2 down the autoconf/autotool sink hole=
=2E

Thanks! The changes I submitted should generally be good enough for
distro maintainers to avoid Makefile modifications.

Cheers,

Pavel
