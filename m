From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] via-rhine: references __init code during resume
Date: Sat, 30 Oct 2004 09:02:42 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <418390F2.7080901@pobox.com>
References: <4179543F.1020407@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, rl@hellgate.ch
Return-path: <netdev-bounce@oss.sgi.com>
To: "Randy.Dunlap" <rddunlap@osdl.org>
In-Reply-To: <4179543F.1020407@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Randy.Dunlap wrote:
> 
> 
> ------------------------------------------------------------------------
> 
> 
> Fix __init section usage:
> rhine_resume calls enable_mmio, so latter cannot be __devinit;
> Error: ./drivers/net/via-rhine.o .text refers to 0000000000000925 R_X86_64_PC32     .init.text+0xfffffffffffffffc
> 
> Signed-off-by: Randy Dunlap <rddunlap@osdl.org>

Attaching patches in this way breaks Linus's patch merge scripts (which 
I use), causing the description to be completely omitted.

Please include descriptions and patches inline.  "sendmail -t < mail" 
works well for this.  You need only supply the From, To, and Subject 
headers, and a blank line, in order for this to work.

	Jeff
