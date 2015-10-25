From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: openvswitch: net --> net-next merge
Date: Sat, 24 Oct 2015 17:20:14 -0700
Message-ID: <CALnjE+rBUPaKB1MHvscAEgUwwZAG+HSRJeN3RgVwmzw++gvfqg@mail.gmail.com>
References: <20151024.065556.1808313684538753807.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Joe Stringer <joestringer@nicira.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:33048 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752528AbbJYAUP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2015 20:20:15 -0400
Received: by igbkq10 with SMTP id kq10so54473901igb.0
        for <netdev@vger.kernel.org>; Sat, 24 Oct 2015 17:20:14 -0700 (PDT)
In-Reply-To: <20151024.065556.1808313684538753807.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 24, 2015 at 6:55 AM, David Miller <davem@davemloft.net> wrote:
>
> I needed to do a merge of 'net' into 'net-next' in order to
> facilitate a set of tipc patches that I wanted to apply to
> 'net-next'.
>
> There were several openvswitch merge conflicts, mostly to do with the
> egress tunnel info bug fix conflicting with the simplification of the
> vport ->send() method.
>
> I did my best to resolve the conflicts, but if someone would double
> check my work I would really appreciate it.
>

Resolved conflicts looks good. There is one minor issue where unused
function (ovs_tunnel_route_lookup) is not removed, I will send out
patch to fix it.
