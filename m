From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [net v3] veth: advertise peer link once both links are tied
 together
Date: Fri, 10 Jun 2016 15:15:01 +0200
Message-ID: <575ABD55.7020202@6wind.com>
References: <574C6095.9050804@6wind.com>
 <1464623917-11536-1-git-send-email-vincent@bernat.im>
 <87bn3n358j.fsf@zoro.exoscale.ch> <574C69DE.3050305@6wind.com>
 <m3fusyg2pi.fsf@neo.luffy.cx> <574D56A0.3090606@6wind.com>
 <694175272.49661350.1465417849878.JavaMail.zimbra@redhat.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Vijay Pandurangan <vijayp@vijayp.ca>,
	Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org
To: Lance Richardson <lrichard@redhat.com>,
	Vincent Bernat <vincent@bernat.im>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:34753 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161003AbcFJNPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 09:15:05 -0400
Received: by mail-wm0-f52.google.com with SMTP id k184so2979055wme.1
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2016 06:15:04 -0700 (PDT)
In-Reply-To: <694175272.49661350.1465417849878.JavaMail.zimbra@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 08/06/2016 22:30, Lance Richardson a =C3=A9crit :
[snip]
> I've been pondering how to fix this very problem off-and-on for a few=
 months
> now, without having arrived at any solution that was particularly sat=
isfying.
>=20
> The main constraints I've been trying to meet are:
>    - User-space should be informed of veth pairing for both peers.
>    - RTM_NEWLINK messages should not refer to interfaces that haven't
>      been announced to user-space via previous RTM_NEWLINK messages.
>    - The first (and only the first) RTM_NEWLINK message for a given
>      interface should have ifi_changes set to ~0U, subsequent RTM_NEW=
LINK
>      messages should have ifi_changes set to reflect the flags that
>      have changed.
>=20
> This is the closest I've come to a satisfactory solution, it does mee=
t
> the above constraints but still seems a little unnatural to me:
The patch looks good to me. Can you submit it formally?
