From: Gabriel C <nix.or.die@googlemail.com>
Subject: Re: appletalk bugs
Date: Mon, 22 Oct 2007 21:45:18 +0200
Message-ID: <471CFDCE.9090702@googlemail.com>
References: <471CB159.1070706@googlemail.com> <m18x5vasif.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.190]:45278 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753685AbXJVTpn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 15:45:43 -0400
Received: by mu-out-0910.google.com with SMTP id i10so2143494mue
        for <netdev@vger.kernel.org>; Mon, 22 Oct 2007 12:45:42 -0700 (PDT)
In-Reply-To: <m18x5vasif.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> Gabriel C <nix.or.die@googlemail.com> writes:
> 
>> Hi,
>>
>> modprobing appletalk on current git gives a warning in dmesg :
>>
>> [38506.600269] sysctl table check failed: /net/appletalk .3.7 procname does not
>> match binary path procname
> 
> Oops.  My apologies it appears I made a mistake when creating my
> table to check up on sysctl values.
> 
> This should fix it.

Yes it does, thx.

> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> ---
> 
> diff --git a/kernel/sysctl_check.c b/kernel/sysctl_check.c
> index 3c9ef5a..ed6fe51 100644
> --- a/kernel/sysctl_check.c
> +++ b/kernel/sysctl_check.c
> @@ -731,7 +731,7 @@ static struct trans_ctl_table trans_net_table[] = {
>  	{ NET_UNIX,		"unix",		trans_net_unix_table },
>  	{ NET_IPV4,		"ipv4",		trans_net_ipv4_table },
>  	{ NET_IPX,		"ipx",		trans_net_ipx_table },
> -	{ NET_ATALK,		"atalk",	trans_net_atalk_table },
> +	{ NET_ATALK,		"appletalk",	trans_net_atalk_table },
>  	{ NET_NETROM,		"netrom",	trans_net_netrom_table },
>  	{ NET_AX25,		"ax25",		trans_net_ax25_table },
>  	{ NET_BRIDGE,		"bridge",	trans_net_bridge_table },
> 
