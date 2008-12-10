From: Hitoshi Mitake <mitake@clustcom.com>
Subject: Re: [RFC] New functions to manipulate registers for ethtool
Date: Wed, 10 Dec 2008 20:26:18 +0900
Message-ID: <20081210202618.0f2a2218.mitake@clustcom.com>
References: <20081208171230.288c5ccf.mitake@clustcom.com>
	<20081208.005431.200957157.davem@davemloft.net>
	<58622.1228726903@turing-police.cc.vt.edu>
	<20081208.010634.247305010.davem@davemloft.net>
	<F169D4F5E1F1974DBFAFABF47F60C10A1753409B@orsmsx507.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"Valdis.Kletnieks@vt.edu" <Valdis.Kletnieks@vt.edu>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"ktaka@clustcom.com" <ktaka@clustcom.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from i220-221-252-159.s30.a048.ap.plala.or.jp ([220.221.252.159]:57873
	"EHLO mail.m.clustcom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751127AbYLJL0a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 06:26:30 -0500
In-Reply-To: <F169D4F5E1F1974DBFAFABF47F60C10A1753409B@orsmsx507.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 8 Dec 2008 09:36:53 -0800
"Brandeburg, Jesse" <jesse.brandeburg@intel.com> wrote:

> David Miller wrote:
> > From: Valdis.Kletnieks@vt.edu
> > Date: Mon, 08 Dec 2008 04:01:43 -0500
> > 
> >> On Mon, 08 Dec 2008 00:54:31 PST, David Miller said:
> >>> From: Hitoshi Mitake <mitake@clustcom.com>
> >>> Date: Mon, 8 Dec 2008 17:12:30 +0900
> >>> 
> >>>> I want to add two new functions to ethtool.
> >>>> 
> >>>> One is for setting driver's registers on MMIO area like
> >>>> --change-eeprom option.
> >>> 
> >>> You can map the registers into userspace using the bus
> >>> level mmap facilities exported to userspace.
> 
> one hiccup, Arjan recently added functionality to the kernel that could
> disallow this unless a user overrides at boot. [1]
> 
> also, there is a .config option that disallows this but I'm just
> mentioning it for posterity.
> 
> >>> No ethtool support is necessary for this.
> >> 
> >> Yes, but if Hitoshi wants to tell a user "run this command and send
> >> me the output", what's the incantation the user needs to use?
> > 
> 
> ethregs -s <bus>:<dev>.<fn>
> 
> > That's an awful reason to have to two ways of doing the exact same
> > thing from userspace.
> > 
> > Write the tool.  Someone will if it's important enough (in fact
> > such code probably exists already).

Thanks for your replying, David, Valdis and Jesse.

> 
> Hi Hitoshi,
> you probably want to download and install our ethregs utility.
> http://prdownloads.sf.net/e1000/ethregs-1.1.tar.gz
> (this is not a direct link as it seems but gets redirected to a mirror
> page, usually)
> 

This is a nice software for me, Thanks.

> Please let me know if it doesn't support your device ID.

I used this on my environment.
My NICs are 82573L and 82573E. ethregs could detected them well.

It seems that this program doesn't support for writing value to registers.
I think making ethregs to support writing is not bad idea.
If you are not planning, I want to do that.

I'm not a professional of Intel's NICs.
How do you think?
