From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: netlink circular locking dependency
Date: Wed, 18 Jun 2008 06:15:56 +0000
Message-ID: <20080618061556.GA4012@ff.dom.local>
References: <20080617132410.GB4632@ff.dom.local> <4857BBB6.6010709@trash.net> <20080617134303.GC4632@ff.dom.local> <20080617.213012.132043917.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, marcel@holtmann.org, netdev@vger.kernel.org,
	mingo@elte.hu, tgraf@suug.ch
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:36740 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758356AbYFRGLl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 02:11:41 -0400
Received: by ug-out-1314.google.com with SMTP id h2so718044ugf.16
        for <netdev@vger.kernel.org>; Tue, 17 Jun 2008 23:11:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080617.213012.132043917.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 17, 2008 at 09:30:12PM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Tue, 17 Jun 2008 13:43:03 +0000
> 
> > On Tue, Jun 17, 2008 at 03:27:18PM +0200, Patrick McHardy wrote:
> > ...
> > > I guess that might work. But simply using module references to
> > > prevent the module from going away while the mutex is not held
> > > doesn't appear to be more complicated.
> > 
> > O.K.
> 
> In the meantime should I apply Patrick's current patch
> from this thread?
> 
> If so I'd like a proper commit message and signoff, thanks!

I hope this is a question "To:" Patrick... (I'm OK with any
version of this patch as a temporary solution.)

Regards,
Jarek P.
