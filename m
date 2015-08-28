From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH v2 net-next 2/4] ip_tunnels: record IP version in tunnel info
Date: Fri, 28 Aug 2015 15:55:55 -0700
Message-ID: <CALnjE+p2t4-uTVv5LXq3wTV3rBfmNcBS33yvgXd5ytQkXdTJfg@mail.gmail.com>
References: <cover.1440787600.git.jbenc@redhat.com>
	<5f1807433565275c8bf699c0495b66c620b274c7.1440787600.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:34931 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753187AbbH1Wz4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 18:55:56 -0400
Received: by ioed140 with SMTP id d140so21319096ioe.2
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 15:55:55 -0700 (PDT)
In-Reply-To: <5f1807433565275c8bf699c0495b66c620b274c7.1440787600.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 28, 2015 at 11:48 AM, Jiri Benc <jbenc@redhat.com> wrote:
> There's currently nothing preventing directing packets with IPv6
> encapsulation data to IPv4 tunnels (and vice versa). If this happens,
> IPv6 addresses are incorrectly interpreted as IPv4 ones.
>
> Track whether the given ip_tunnel_key contains IPv4 or IPv6 data. Store this
> in ip_tunnel_info. Reject packets at appropriate places if they are supposed
> to be encapsulated into an incompatible protocol.
>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> Acked-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
> v2: moved the af check in geneve before the first usage of tunnel info data
> ---
Acked-by: Pravin B Shelar <pshelar@nicira.com>
