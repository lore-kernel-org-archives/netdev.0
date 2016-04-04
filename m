From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] ip6_tunnel: set rtnl_link_ops before calling
 register_netdevice
Date: Mon, 4 Apr 2016 09:51:31 +0200
Message-ID: <57021D03.8010005@6wind.com>
References: <1459541870-26938-1-git-send-email-cascardo@redhat.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:34712 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751356AbcDDHve (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 03:51:34 -0400
Received: by mail-lb0-f174.google.com with SMTP id vo2so147780330lbb.1
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 00:51:34 -0700 (PDT)
In-Reply-To: <1459541870-26938-1-git-send-email-cascardo@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 01/04/2016 22:17, Thadeu Lima de Souza Cascardo a =C3=A9crit :
> When creating an ip6tnl tunnel with ip tunnel, rtnl_link_ops is not s=
et
> before ip6_tnl_create2 is called. When register_netdevice is called, =
there
> is no linkinfo attribute in the NEWLINK message because of that.
>
> Setting rtnl_link_ops before calling register_netdevice fixes that.
>
> Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
=46ixes: 0b112457229d ("ip6tnl: add support of link creation via rtnl")
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
