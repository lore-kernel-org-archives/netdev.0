From: chas williams (contractor) <chas@cmf.nrl.navy.mil>
Subject: Re: Fw: [Kernel-janitors] net/atm/clip.c: check kmem_cache_create() #1
Date: Thu, 05 Feb 2004 13:48:55 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402051848.i15ImrRr005748@ginger.cmf.nrl.navy.mil>
References: <romieu@fr.zoreil.com>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: Message from Francois Romieu <romieu@fr.zoreil.com>
   of "Thu, 05 Feb 2004 19:38:13 +0100." <20040205193813.A4230@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20040205193813.A4230@electric-eye.fr.zoreil.com>,Francois Romieu wr
ites:
>As long as the ugly-ifdef patrol does not bite, it's fine with me. :o)

it would less ugly if people could accept a possibly unused stack
variable for the !CONFIG_PROC_FS case.

>It would not hurt. Do you have a specific race in mind before I send
>an update on top your patch for the clip_tbl_hook -> clip_tbl change ?

no particular race.  just that the arp /proc entry should not be available
until clip gets initialized.  clip_tbl_hook should only be used by 
net/ipv4/arp.c really.
