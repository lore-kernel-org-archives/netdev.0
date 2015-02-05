From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH 00/29] net: VRF support
Date: Thu, 05 Feb 2015 14:44:20 +0100
Message-ID: <54D373B4.3050603@6wind.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ebiederm@xmission.com
To: David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:34567 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753264AbbBENoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 08:44:24 -0500
Received: by mail-wi0-f175.google.com with SMTP id fb4so38989509wid.2
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 05:44:23 -0800 (PST)
In-Reply-To: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/02/2015 02:34, David Ahern a =C3=A9crit :
[snip]
> This is accomplished by enhancing the current namespace checks to a
> broader network context that is both a namepsace and a VRF id. The VR=
=46
> id is a tag applied to relevant structures, an integer between 1 and =
4095
> which allows for 4095 VRFs (could have 0 be the default VRF and then =
the
> range is 0-4095 =3D 4096s VRFs). (The limitation is arguably artifici=
al. It
> is based on the genid scheme for versioning networking data which is =
a
> 32-bit integer. The VRF id is the lower 12 bits of the genid's.)
Would it be possible to avoid this artificial limit?
There could be scenarii with more than 4096 vrf.

Do you plan to have a way to dump or monitor VRF via netlink?
