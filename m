From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [bug 2.6.4] llc2 oops
Date: Mon, 15 Mar 2004 14:20:16 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403151420.19986.acme@conectiva.com.br>
References: <Pine.LNX.4.58.0403141732350.25924@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jochen Friedrich <jochen@scram.de>
In-Reply-To: <Pine.LNX.4.58.0403141732350.25924@localhost>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sunday 14 March 2004 13:49, Jochen Friedrich wrote:
> Hi,


> fffffffc005831d4
> 
> So, apparently, llc_ui_wait_for_conn() and llc_ui_wait_for_disc() are
> buggy, as well...


Oh well, yes, the code has lots of bugs as it is currently in the tree, I have 
it rewritten in my net-experimental tree, that has lots of other changes 
(mostly renames, moving buttloads of stuff from net/ipv4 to net/core, etc) to
core code, tcp/ip v4/v6, sctp, etc, making most protocols use more and
more common infrastructure, its solid, but I don't have time right now to
work on chunk it to send to Dave, will do it, I hope, this month.

But hey, if you are really interested in llc2 let me know and I'll send you
my latest patches (IIRC they are at my 
www.kernel.org/pub/linux/kernel/people/acme area).

FWIW I have patches for ncftp, vsftpd, openssh, etc making them use
PF_LLC, mostly transparent, just not for vsftpd, that reivents the
get{name,addr}info wheel for some reason 8)

- Arnaldo
