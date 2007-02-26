From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: Re: possible bug in net/tc35815.c in linux-2.6.19
Date: Mon, 26 Feb 2007 23:07:47 +0300
Message-ID: <45E33E13.7010007@ru.mvista.com>
References: <45E031A3.806@googlemail.com>	<45E0B651.2050601@garzik.org>	<20070226102659.GA28439@linux-mips.org> <20070226.200554.125898248.nemoto@toshiba-tops.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, jeff@garzik.org,
	michal.k.k.piotrowski@gmail.com, pg@cs.stanford.edu,
	ahennessy@mvista.com, netdev@vger.kernel.org,
	linux-mips@linux-mips.org
To: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h155.mvista.com ([63.81.120.155]:59982 "EHLO imap.sh.mvista.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1030634AbXBZUIF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Feb 2007 15:08:05 -0500
In-Reply-To: <20070226.200554.125898248.nemoto@toshiba-tops.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Atsushi Nemoto wrote:

> I know both MontaVista and CELF have new driver for the chip.  If
> anybody in MontaVista did not complain I can send CELF's one available
> at http://tree.celinuxforum.org/pubwiki/moin.cgi/PatchArchive.  (it

    Yeah, tc35815_1.c in our looks like the one in the CELF archive (what I 
didn't get is why they decided to keep both drivers around?)

> needs some changes for recent kernel, for example pt_regs removal, but
> it would be easy).

> Sergei?

    I think everybody would be just thankful. :-)
    There's quite a lot of other TX4938 patches that need pushing into 
Linux/MIPS -- unfortunetely, this hasn't been done by MV... :-<

> ---
> Atsushi Nemoto

    BTW, does RBTX4938 boot the recent kernels for you? If so, what .config 
are you using -- I'm afraid something's up with rbhma4500_defconfig?

WBR, Sergei
