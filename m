From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH] bonding: document two undocumented options.
Date: Wed, 03 Aug 2011 22:01:11 +0200
Message-ID: <4E39A907.5040408@gmail.com>
References: <1312315615-5739-1-git-send-email-nicolas.2p.debian@free.fr> <20110803.034425.1421983987148421662.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nicolas.2p.debian@free.fr, fubar@us.ibm.com, andy@greyhouse.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:54291 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752605Ab1HCUBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2011 16:01:16 -0400
Received: by wyf22 with SMTP id 22so80977wyf.19
        for <netdev@vger.kernel.org>; Wed, 03 Aug 2011 13:01:14 -0700 (PDT)
In-Reply-To: <20110803.034425.1421983987148421662.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 03/08/2011 12:44, David Miller a =E9crit :
> From: Nicolas de Peslo=FCan<nicolas.2p.debian@free.fr>
> Date: Tue,  2 Aug 2011 22:06:55 +0200
>
>> Commit 655f8919d549ad1872e24d826b6ce42530516d2e
>>      bonding: add min links parameter to 802.3ad
>>
>> and commit ebd8e4977a87cb81d93c62a9bff0102a9713722f
>>      bonding: add all_slaves_active parameter
>>
>> introduced new options to bonding, but didn't provide the documentat=
ion
>> for those options.
>>
>> Signed-off-by: Nicolas de Peslo=FCan<nicolas.2p.debian@free.fr>
>
> Please explicitly mention in each new entry what the default
> setting is.

Unfortunately, I failed to find a place in the bonding code where the m=
ax_links option is=20
initialized with a default value. So I must assume default value is zer=
o which should cause carrier=20
to always be asserted, or undefined, which should cause interesting sid=
e effects...

The obvious default value should be 1, but I cannot confirm it is.

Stephen, as the author of this feature, can you please clarify what the=
 default value for min_links is?

V2 will follow, giving the real default value for all_slaves_active and=
 what I consider the sensible=20
default value for max_links, even if the technical real default value i=
s currently unclear.

	Nicolas.
