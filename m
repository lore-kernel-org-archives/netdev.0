From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] drivers/net: add 6WIND SHULTI support
Date: Thu, 28 Apr 2016 13:59:34 +0200
Message-ID: <5721FB26.6070305@6wind.com>
References: <1461749838-4613-1-git-send-email-nicolas.dichtel@6wind.com>
 <20160427095615.GA27071@breakpoint.cc>
 <20160427151336.GB1962@nanopsycho.orion>
 <20160427.125506.1088576804354580011.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fw@strlen.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:38476 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751505AbcD1L7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 07:59:50 -0400
Received: by mail-wm0-f43.google.com with SMTP id g17so37299242wme.1
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 04:59:49 -0700 (PDT)
In-Reply-To: <20160427.125506.1088576804354580011.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 27/04/2016 18:55, David Miller a =E9crit :
> From: Jiri Pirko <jiri@resnulli.us>
[snip]
>> The difference is that it this tries to allow userspace crap to mirr=
or
>> setting user does for bridge/ovs. Basically this looks to me like an
>> attempt to enable userspace SDKs and such.
>=20
> +1
I don't think so because a userspace can receive all the bridge/ovs set=
tings by
mean of netlink mirror, without the need for this driver at all.
