From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 7/7] soreuseport: BPF selection functional test
 for TCP
Date: Fri, 5 Feb 2016 18:59:27 -0800
Message-ID: <20160206025925.GA68256@ast-mbp.thefacebook.com>
References: <1454600118-30152-1-git-send-email-kraigatgoog@gmail.com>
 <1454600118-30152-8-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33294 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751166AbcBFC7a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 21:59:30 -0500
Received: by mail-pa0-f42.google.com with SMTP id cy9so43627788pac.0
        for <netdev@vger.kernel.org>; Fri, 05 Feb 2016 18:59:30 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1454600118-30152-8-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 04, 2016 at 10:35:18AM -0500, Craig Gallek wrote:
> From: Craig Gallek <kraig@google.com>
> 
> Unfortunately the existing test relied on packet payload in order to
> map incoming packets to sockets.  In order to get this to work with TCP,
> TCP_FASTOPEN needed to be used.
> 
> Since the fast open path is slightly different than the standard TCP path,
> I created a second test which sends to reuseport group members based
> on receiving cpu core id.  This will probably serve as a better
> real-world example use as well.
> 
> Signed-off-by: Craig Gallek <kraig@google.com>

nice tests and looks very straightforward to use.

Acked-by: Alexei Starovoitov <ast@kernel.org>
