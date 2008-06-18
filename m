From: David Miller <davem@davemloft.net>
Subject: Re: netlink circular locking dependency
Date: Wed, 18 Jun 2008 02:08:31 -0700 (PDT)
Message-ID: <20080618.020831.214323427.davem@davemloft.net>
References: <20080617134303.GC4632@ff.dom.local>
	<20080617.213012.132043917.davem@davemloft.net>
	<4858CCCE.7060404@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, marcel@holtmann.org, netdev@vger.kernel.org,
	mingo@elte.hu, tgraf@suug.ch
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56116
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751167AbYFRJIa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 05:08:30 -0400
In-Reply-To: <4858CCCE.7060404@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 18 Jun 2008 10:52:30 +0200

> David Miller wrote:
> > In the meantime should I apply Patrick's current patch
> > from this thread?
> 
> I think that makes sense, the module unload race is present anyway.
> >
> > If so I'd like a proper commit message and signoff, thanks!
> 
> Attached the patch with a proper changelog.

Applied and pushed out to net-2.6, thanks a lot Patrick.
