From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 2/2] tc: m_tunnel_key: add csum/nocsum option
Date: Wed, 14 Jun 2017 13:38:07 -0700
Message-ID: <20170614133807.2320f98b@xeon-e3>
References: <cover.1497467840.git.jbenc@redhat.com>
        <20170614213018.364cd85d@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:34760 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751760AbdFNUiP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 16:38:15 -0400
Received: by mail-pg0-f48.google.com with SMTP id v18so5074926pgb.1
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 13:38:14 -0700 (PDT)
In-Reply-To: <20170614213018.364cd85d@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Jun 2017 21:30:18 +0200
Jiri Benc <jbenc@redhat.com> wrote:

> Allows control of UDP zero checksum.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
>  man/man8/tc-tunnel_key.8 | 18 ++++++++++++++++++
>  tc/m_tunnel_key.c        | 21 ++++++++++++++++++++-
>  2 files changed, 38 insertions(+), 1 deletion(-)
> 
> diff --git a/man/man8/tc-tunnel_key.8 b/man/man8/tc-tunnel_key.8
> index 2e569730abbb..e979a74715cb 100644
> --- a/man/man8/tc-tunnel_key.8
> +++ b/man/man8/tc-tunnel_key.8
> @@ -16,6 +16,7 @@ tunnel_key - Tunnel metadata manipulation
>  .IR ADDRESS
>  .BI id " KEY_ID"
>  .BI dst_port " UDP_PORT"
> +.RB "[ " csum " | " nocsum " ]"
>  
>  .SH DESCRIPTION
>  The
> @@ -77,6 +78,23 @@ Outer header destination IP address (IPv4 or IPv6)
>  .TP
>  .B dst_port
>  Outer header destination UDP port
> +.TP
> +.RB [ no ] csum
> +Controlls outer UDP checksum. When set to
> +.B csum
> +(which is default), the outer UDP checksum is calculated and included in the
> +packets. When set to
> +.BR nocsum ,

Does this change the default? Before your patches what was the checksum
setting for the new tunnel.
