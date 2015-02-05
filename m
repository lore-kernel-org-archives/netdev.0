From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH 19/29] net: vrf: Add vrf context to skb
Date: Thu, 05 Feb 2015 14:45:56 +0100
Message-ID: <54D37414.104@6wind.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com> <1423100070-31848-20-git-send-email-dsahern@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ebiederm@xmission.com
To: David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:44035 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753137AbbBENp6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 08:45:58 -0500
Received: by mail-wi0-f177.google.com with SMTP id r20so10636634wiv.4
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 05:45:57 -0800 (PST)
In-Reply-To: <1423100070-31848-20-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/02/2015 02:34, David Ahern a =C3=A9crit :
> On ingress skb's inherit vrf context from the net_device. For TX skb'=
s
> inherit the vrf context from the socket originating the packet. Updat=
e
> SKB related net_ctx macros to set vrf.
Is it really needed to have this skb->vrf?
Is it not possible to get the vrf from sockets, interfaces, etc? Like i=
t's done
with netns?
