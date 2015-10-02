From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v2 1/4] openvswitch: add tunnel protocol to sw_flow_key
Date: Thu, 1 Oct 2015 17:10:52 -0700
Message-ID: <CALnjE+p_Rt-QYaT_X4Fmdrp8YLQN7HRZz39yyv3oCi9Z0A1ocw@mail.gmail.com>
References: <cover.1443710454.git.jbenc@redhat.com>
	<c3cd5405d57793d2d9e84f2c5bdd0438cf68d980.1443710454.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Jesse Gross <jesse@nicira.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:33623 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803AbbJBAKx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 20:10:53 -0400
Received: by igbkq10 with SMTP id kq10so7814258igb.0
        for <netdev@vger.kernel.org>; Thu, 01 Oct 2015 17:10:52 -0700 (PDT)
In-Reply-To: <c3cd5405d57793d2d9e84f2c5bdd0438cf68d980.1443710454.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 1, 2015 at 7:44 AM, Jiri Benc <jbenc@redhat.com> wrote:
> Store tunnel protocol (AF_INET or AF_INET6) in sw_flow_key. This field now
> also acts as an indicator whether the flow contains tunnel data (this was
> previously indicated by tun_key.u.ipv4.dst being set but with IPv6 addresses
> in an union with IPv4 ones this won't work anymore).
>
> The new field was added to a hole in sw_flow_key.
>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
> v2: Set the tun_proto mask to 0xff in ip_tun_from_nlattr.
> ---
Acked-by: Pravin B Shelar <pshelar@nicira.com>
