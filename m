From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v2] ipv4: add support for linkdown sysctl to
 netconf
Date: Wed, 08 Jul 2015 11:43:50 +0200
Message-ID: <559CF0D6.3090602@6wind.com>
References: <1436291817-1555-1-git-send-email-gospo@cumulusnetworks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Andy Gospodarek <gospo@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:34408 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934431AbbGHJnx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 05:43:53 -0400
Received: by wgov12 with SMTP id v12so5935341wgo.1
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 02:43:52 -0700 (PDT)
In-Reply-To: <1436291817-1555-1-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 07/07/2015 19:56, Andy Gospodarek a =C3=A9crit :
> This kernel patch exports the value of the new
> ignore_routes_with_linkdown via netconf.
>
> v2: changes to notify userspace via netlink when sysctl values change
> and proposed for 'net' since this could be considered a bugfix
Hmm, commit title contains net-next, not net.

>
> Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
> Suggested-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

> ---
> I realize two of these changes result in lines >80 chars, but this is=
 to
> keep the coding-style used by the surrounding code.
>
> There are multiple ways to resolve this, but one would be to shorten =
the
> defines used for this feature as "IGNORE_ROUTES_WITH_LINKDOWN" is a
> mouthful.  I would propose dropping "_WITH_" from all the defines and
> have only "IGNORE_ROUTES_LINKDOWN" everywhere.  Doing this now in 'ne=
t'
Yes. Or even shorter: IGNORE_NH_LINKDOWN?

> would be ideal before a release happens and it cannot be changed.
Yes.
