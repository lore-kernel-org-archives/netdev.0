From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH v2 net-next 1/4] ip_tunnels: convert the mode field of
 ip_tunnel_info to flags
Date: Fri, 28 Aug 2015 15:55:51 -0700
Message-ID: <CALnjE+qZJH3x3ifBYBhSQe4AKtN+X1YWNnP623AMPsrh711AwQ@mail.gmail.com>
References: <cover.1440787600.git.jbenc@redhat.com>
	<19c04b86fdfd059ec3b74f997b008702787e6450.1440787600.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:36218 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752770AbbH1Wzv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 18:55:51 -0400
Received: by ioej130 with SMTP id j130so26522118ioe.3
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 15:55:51 -0700 (PDT)
In-Reply-To: <19c04b86fdfd059ec3b74f997b008702787e6450.1440787600.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 28, 2015 at 11:48 AM, Jiri Benc <jbenc@redhat.com> wrote:
> The mode field holds a single bit of information only (whether the
> ip_tunnel_info struct is for rx or tx). Change the mode field to bit flags.
> This allows more mode flags to be added.
>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> Acked-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
> v2: converted geneve fully, too
> ---
Acked-by: Pravin B Shelar <pshelar@nicira.com>
