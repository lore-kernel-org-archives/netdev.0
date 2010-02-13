From: Andreas Petlund <apetlund@simula.no>
Subject: Re: [net-next PATCH v3 3/3] net: TCP thin dupack
Date: Sat, 13 Feb 2010 16:50:19 +0100
Message-ID: <4B76CA3B.4010206@simula.no>
References: <4B73F31F.9000204@simula.no> <4B753943.2080800@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	=?UTF-8?B?SWxwbyBK?= =?UTF-8?B?w6RydmluZW4=?=
	<ilpo.jarvinen@helsinki.fi>, Eric Dumazet <eric.dumazet@gmail.com>,
	Arnd Hannemann <hannemann@nets.rwth-aachen.de>,
	LKML <linux-kernel@vger.kernel.org>, shemminger@vyatta.com,
	David Miller <davem@davemloft.net>, damian@tvk.rwth-aachen.de
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.2750.no ([62.101.244.198]:59382 "EHLO mail.2750.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757261Ab0BMP6M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Feb 2010 10:58:12 -0500
In-Reply-To: <4B753943.2080800@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12. feb. 2010 12:19, William Allen Simpson wrote:
> Last year, I'm pretty sure I was on record as thinking this is *not* a
> good idea.  But at least it now requires a sysctl to turn on, and
> should default to off.
> 
> Also that naming was a bit dicey.  Now the names are more descriptive,
> but the "force" is a bit overkill.
> 
> How about:
>   NET_TCP_FORCE_THIN_LINEAR_DUPACK -> NET_TCP_THIN_LINEAR_DUPACK
>   tcp_force_thin_dupack            -> tcp_thin_linear_dupack
>   sysctl_tcp_force_thin_dupack     -> sysctl_tcp_thin_linear_dupack

You uncovered a copy/paste/edit-typo there. The term "linear" had snuck
in even though it does not make sense for this patch. I think that
NET_TCP_THIN_DUPACK, tcp_thin_dupack and sysctl_tcp_thin_dupack will
be better.

Best regards,
Andreas
