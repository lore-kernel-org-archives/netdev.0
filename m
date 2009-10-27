From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH] sh_eth: Add asm/cacheflush.h
Date: Tue, 27 Oct 2009 09:25:25 +0900
Message-ID: <20091027002525.GA17085@linux-sh.org>
References: <29ab51dc0910261649p2fb22799o5cc70a71dff0f1dd@mail.gmail.com> <20091026.171956.110203653.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: iwamatsu@nigauri.org, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 124x34x33x190.ap124.ftth.ucom.ne.jp ([124.34.33.190]:53605 "EHLO
	master.linux-sh.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753911AbZJ0AZ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 20:25:27 -0400
Content-Disposition: inline
In-Reply-To: <20091026.171956.110203653.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 26, 2009 at 05:19:56PM -0700, David Miller wrote:
> From: Nobuhiro Iwamatsu <iwamatsu@nigauri.org>
> Date: Tue, 27 Oct 2009 08:49:50 +0900
> 
> > Add include asm/cacheflush.h,  because declaration of __flush_purge_region
> > moved to asm/cacheflush.h.
> > 
> > Signed-off-by: Nobuhiro Iwamatsu <iwamatsu@nigauri.org>
> 
> Applied, thanks.

Even though Iwamatsu-san didn't specify the kernel version, this is
relevant for 2.6.32 (as that's where we made the change).
