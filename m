From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Fw: [Kernel-janitors] net/atm/clip.c: check kmem_cache_create() #1
Date: Thu, 5 Feb 2004 19:38:13 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040205193813.A4230@electric-eye.fr.zoreil.com>
References: <romieu@fr.zoreil.com> <200402051222.i15CMcRr029937@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Randy.Dunlap" <rddunlap@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas williams <chas@cmf.nrl.navy.mil>
Content-Disposition: inline
In-Reply-To: <200402051222.i15CMcRr029937@ginger.cmf.nrl.navy.mil>; from chas@cmf.nrl.navy.mil on Thu, Feb 05, 2004 at 07:22:40AM -0500
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

chas williams <chas@cmf.nrl.navy.mil> :
[...]
> how about the following instead?  we probably shouldnt register the

As long as the ugly-ifdef patrol does not bite, it's fine with me. :o)

> proc entry until clip_tbl is going to be ready for use anyway (the
> arp table iterators should probably also use clip_tbl instead of
> clip_tbl_hook).

It would not hurt. Do you have a specific race in mind before I send
an update on top your patch for the clip_tbl_hook -> clip_tbl change ?

--
Ueimor
