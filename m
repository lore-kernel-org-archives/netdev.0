From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [RFC] dependencies for platform drivers (was Re: ax88796: add superh to kconfig dependencies)
Date: Fri, 9 Nov 2007 18:40:23 +0900
Message-ID: <20071109094023.GA7022@linux-sh.org>
References: <20071108073105.3996.70418.sendpatchset@clockwork.opensource.se> <20071108081854.GN8181@ftp.linux.org.uk> <20071109092652.GA13350@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Al Viro <viro@ftp.linux.org.uk>,
	Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
	ben-linux@fluff.org, akpm@linux-foundation.org, jeff@garzik.org,
	linux-arch@vger.kernel.org
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pip10.gyao.ne.jp ([61.122.117.248]:17792 "EHLO mx.gate01.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751523AbXKIJlF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Nov 2007 04:41:05 -0500
Content-Disposition: inline
In-Reply-To: <20071109092652.GA13350@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 09, 2007 at 09:26:52AM +0000, Ralf Baechle wrote:
> If writesb() is not an official API then maybe the answer should have been
> to either add that API to other architectures or fix the driver.
> 
> I guess this incident means I need to go through all Kconfig* files to
> see what bogus architecture dependencies on MIPS or !MIPS exist ...
> 
While writesb() isn't an official API, the iowriteX_rep() interfaces
theoretically are. Tidying up the driver for iomap is probably a better
option.
