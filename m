From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH stable 3.11] sit: amend "allow to use rtnl ops on fb tunnel"
Date: Tue, 22 Oct 2013 17:43:49 +0200
Message-ID: <52669D35.4040103@6wind.com>
References: <1382453958-32376-1-git-send-email-willemb@google.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Willem de Bruijn <willemb@google.com>, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:63017 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752860Ab3JVPny (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 11:43:54 -0400
Received: by mail-wi0-f171.google.com with SMTP id h11so5914514wiv.4
        for <netdev@vger.kernel.org>; Tue, 22 Oct 2013 08:43:52 -0700 (PDT)
In-Reply-To: <1382453958-32376-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 22/10/2013 16:59, Willem de Bruijn a =C3=A9crit :
> Amend backport to 3.11.y of
>
>   [ Upstream commit 205983c43700ac3a81e7625273a3fa83cd2759b5 ]
>
> The discussion thread in the upstream commit mentions that in
> backports to stable-* branches, the line
>
>    - unregister_netdevice_queue(sitn->fb_tunnel_dev, &list);
>
> must be omitted if that branch does not have commit 5e6700b3bf98
> ("sit: add support of x-netns"). This line has correctly been omitted
> in the backport to 3.10, which indeed does not have that commit.
>
> It was also removed in the backport to 3.11.y, which does have that
> commit.
>
> This causes the following steps to hit a BUG at net/core/dev.c:5039:
>
>    `modprobe sit; rmmod sit`
>
> The bug demonstrates that it causes a device to be unregistered twice=
=2E
> The simple fix is to apply the one line in the upstream commit that
> was dropped in the backport to 3.11 (3783100374653e2e7fbdf68c710f5).
> This brings the logic in line with upstream linux, net and net-next
> branches.
>
> Signed-off-by: Willem de Bruijn <willemb@google.com>
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
