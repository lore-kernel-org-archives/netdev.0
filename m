From: Cacophonix <cacophonix@yahoo.com>
Subject: Re: [PATCH] hp100 -- fixes for new probing.
Date: Tue, 24 Feb 2004 15:36:02 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040224233602.36835.qmail@web14004.mail.yahoo.com>
References: <20040223094925.344bc73d@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040223094925.344bc73d@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thanks for the suggestion.

It appears to be locking up at line 309 in hp100.c, i.e,

    hp100_page(ID_MAC_ADDR);
    (called from hp100_isa_probe1() and hp100_read_id() )

thanks,
karthik

--- Stephen Hemminger <shemminger@osdl.org> wrote:

> 
> There probably is some bug introduced with the recent changes.  The driver tries
> to handle isa, eisa, and pci all with the same infrastructure.  There are two different
> probe paths, one for the module and one for the non-module ISA case.  Could you add
> some
> printk's and see if the problem in the hp100_isa_probe code (happens first), or the
> PCI probe that happens from: 
> 	hp100_module_init -> pci_module_init -> hp100_pci_probe...
> 


__________________________________
Do you Yahoo!?
Yahoo! Mail SpamGuard - Read only the mail you want.
http://antispam.yahoo.com/tools
