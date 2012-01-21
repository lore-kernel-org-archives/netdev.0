From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: Merge ipt_LOG and ip6t_LOG
Date: Sat, 21 Jan 2012 09:33:11 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1201210932390.17879@frira.zrqbmnf.qr>
References: <1327103248-18918-1-git-send-email-richard@nod.at>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com
To: Richard Weinberger <richard@nod.at>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1327103248-18918-1-git-send-email-richard@nod.at>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 2012-01-21 00:47, Richard Weinberger wrote:

>Hi!
>
>These two patches merge ipt_LOG and ip6t_LOG.
>
>I'm not really happy with the iptables patch.
>As it depends on xt_log.h iptables will not compile with old 
>kernel headers.
>Any idea how to deal with this?

iptables always has its own copy of the header set, so there is not 
going to be a problem.
