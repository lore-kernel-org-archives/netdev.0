From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: HELP ipt_hook: happy cracking message
Date: Tue, 27 Apr 2004 13:33:17 +1000
Sender: linux-net-owner@vger.kernel.org
Message-ID: <1083036797.2150.14.camel@bach>
References: <20040426151220.85059.qmail@web41403.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kernerl mail <linux-kernel@vger.kernel.org>, netdev@oss.sgi.com,
	linux-net@vger.kernel.org,
	netfilter <netfilter-devel@lists.netfilter.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: Parag Nemade <cranium2003@yahoo.com>
In-Reply-To: <20040426151220.85059.qmail@web41403.mail.yahoo.com>
List-Id: netdev.vger.kernel.org

On Tue, 2004-04-27 at 01:12, Parag Nemade wrote:
> hi,
>         i modified kernel so that it will create
> /proc/net/myproc file entry.
> the function of this entry is to crate a 16 byte char
> string from random no.s
> i used net_srandom and net_random and sys_time for
> that puspose. the problem is that i write program to
> generate string after 120 seconds but it is changing
> contents of myproc file every seconds. what can i do?
>  Also i am getting ipt_hook: happy cracking. message
> again and again why?

You're sending out IP packets which don't even contain the IP header,
and you're running connection tracking or some filtering.

The message is not serious.

Rusty.
-- 
Anyone who quotes me in their signature is an idiot -- Rusty Russell

