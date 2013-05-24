From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] man: describe --bpf option of ss
Date: Fri, 24 May 2013 08:12:08 -0700
Message-ID: <20130524081208.71ed1bd8@nehalam.linuxnetplumber.net>
References: <1369398341-20145-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:43356 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755033Ab3EXPML (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 11:12:11 -0400
Received: by mail-pa0-f48.google.com with SMTP id kp6so4381879pab.21
        for <netdev@vger.kernel.org>; Fri, 24 May 2013 08:12:10 -0700 (PDT)
In-Reply-To: <1369398341-20145-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 24 May 2013 14:25:41 +0200
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:

> This option has been recently added to ss utility.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  man/man8/ss.8 | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/man/man8/ss.8 b/man/man8/ss.8
> index f03c6d8..7e8d8e8 100644
> --- a/man/man8/ss.8
> +++ b/man/man8/ss.8
> @@ -57,6 +57,9 @@ Print summary statistics. This option does not parse socket lists obtaining
>  summary from various sources. It is useful when amount of sockets is so huge
>  that parsing /proc/net/tcp is painful.
>  .TP
> +.B \-b, \-\-bpf
> +Show socket BPF filters (only administrators are allowed to get these information).
> +.TP
>  .B \-4, \-\-ipv4
>  Display only IP version 4 sockets (alias for -f inet).
>  .TP

applied
