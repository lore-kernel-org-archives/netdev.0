From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Mon, 11 Feb 2008 23:55:33 +0100
Message-ID: <20080211225533.GB2863@ami.dom.local>
References: <200802110922.m1B9MKQ4003674@quickie.katalix.com> <47B09A90.7040508@gmail.com> <47B0C9F7.5040200@katalix.com> <20080211224924.GA2863@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:3166 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756351AbYBKWuc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2008 17:50:32 -0500
Received: by ug-out-1314.google.com with SMTP id z38so402787ugc.16
        for <netdev@vger.kernel.org>; Mon, 11 Feb 2008 14:50:30 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080211224924.GA2863@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 11, 2008 at 11:49:24PM +0100, Jarek Poplawski wrote:
> On Mon, Feb 11, 2008 at 10:19:35PM +0000, James Chapman wrote:
> ...
> > Below is example output from lockdep. The oops is reproducible when  
> > creating/deleting lots of sessions while passing data. The lock is being  
> > acquired for read and write in softirq contexts.

...Hmmm... And according to this, changing read_locks should be
necessary too.

Jarek P.
