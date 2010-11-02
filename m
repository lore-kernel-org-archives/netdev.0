From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH] net: sh_eth: ctrl_in/outX to __raw_read/writeX conversion.
Date: Tue, 2 Nov 2010 22:39:36 +0900
Message-ID: <20101102133936.GC5583@linux-sh.org>
References: <1288666295-12529-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 124x34x33x190.ap124.ftth.ucom.ne.jp ([124.34.33.190]:57692 "EHLO
	master.linux-sh.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752729Ab0KBNjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Nov 2010 09:39:48 -0400
Content-Disposition: inline
In-Reply-To: <1288666295-12529-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 02, 2010 at 11:51:35AM +0900, Nobuhiro Iwamatsu wrote:
> The ctrl_xxx routines are deprecated, switch over to the __raw_xxx
> versions.
> 
> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>

I sent a similar patch yesterday:

http://patchwork.ozlabs.org/patch/69831/

It doesn't matter really which one gets applied, although I opted to use
the accessors with strong ordering given that we'll continue to see this
block in newer CPUs where weak ordering is unlikely to be sufficient.
