From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (regression)] Fragments: fix race between
 inet_frag_find and inet_frag_secret_rebuild
Date: Fri, 27 Jun 2008 20:06:29 -0700 (PDT)
Message-ID: <20080627.200629.124429489.davem@davemloft.net>
References: <4860CFC5.90702@openvz.org>
	<20080624180714.GA3125@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55721
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751858AbYF1DG3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2008 23:06:29 -0400
In-Reply-To: <20080624180714.GA3125@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Tue, 24 Jun 2008 20:07:14 +0200

> Pavel Emelyanov wrote, On 06/24/2008 12:43 PM:
> 
> > The problem is that while we work w/o the inet_frags.lock even
> > read-locked the secret rebuild timer may occur (on another CPU,
> - since BHs are still disables in the inet_frag_find) and change 
> 
> + since BHs are still disabled in the inet_frag_find) and change 

I've applied Pavel's fix with this comment typo cure.

Thanks.
