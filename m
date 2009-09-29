From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Fwd: Re: Bug#538372: header failure including netlink.h (or
	uio.h)]
Date: Tue, 29 Sep 2009 09:27:27 +0000
Message-ID: <20090929092727.GA7025@ff.dom.local>
References: <1254137084.4756.11.camel@ce170155.zmb.uni-duisburg-essen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Manuel Prinz <manuel@debian.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:64493 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753079AbZI2J13 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2009 05:27:29 -0400
Received: by fxm18 with SMTP id 18so4302959fxm.17
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2009 02:27:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1254137084.4756.11.camel@ce170155.zmb.uni-duisburg-essen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28-09-2009 13:24, Manuel Prinz wrote:
> Hi everyone,
> 
> I'm forwarding this bug in Debian (http://bugs.debian.org/538372) as
> requested by the Debian kernel team. A patch is available. Applying just
> the first hunk fixes the issue for me. I've not enough kernel knowledge
> to judge if this fix is a proper solution, though.
> 
> It would be really great if someone could have a look at it. Thanks in
> advance! (And please CC me in replies. Thanks!)

I've tried it with current include/linux and it works OK. Replacing
uio.h on Debian really was not enough, but it looks like missing
compiler.h entries could be the reason. Otherwise, please send your
compile error log.

Best regards,
Jarek P.
