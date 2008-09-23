From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: SCTP checksum patch for 2.6.26.5
Date: Mon, 22 Sep 2008 22:45:18 -0700
Message-ID: <1222148718.16003.1.camel@brick>
References: <48D7C0A2.9090406@protei.ru>
	 <20080922.131245.193705447.davem@davemloft.net>
	 <20080923051920.GD24654@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, nickolay@protei.ru,
	linux-kernel@vger.kernel.org, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.172]:33884 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751912AbYIWFpX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 01:45:23 -0400
Received: by wf-out-1314.google.com with SMTP id 27so2038297wfd.4
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2008 22:45:22 -0700 (PDT)
In-Reply-To: <20080923051920.GD24654@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-09-23 at 07:19 +0200, Willy Tarreau wrote:
> On Mon, Sep 22, 2008 at 01:12:45PM -0700, David Miller wrote:
> > From: Nickolay Vinogradov <nickolay@protei.ru>
> > Date: Mon, 22 Sep 2008 19:58:26 +0400
> > 
> > CC:'ing correct mailing lists...
> > 
> Nickolay,
> 
> you should use swab32(~crc32) instead. It will make use of arch-specific
> optimisations when available (eg: bswap on x86).
> 
> Willy

Or look at:
commit 336d3262df71fcd2661180bb35d5ea41b4cbca58
Author: Harvey Harrison <harvey.harrison@gmail.com>
Date:   Fri Jul 18 23:07:09 2008 -0700

    sctp: remove unnecessary byteshifting, calculate directly in big-endian

In Linus' tree.

Cheers,

Harvey

