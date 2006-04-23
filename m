From: Ingo Oeser <ioe-lkml@rameria.de>
Subject: Re: Van Jacobson's net channels and real-time
Date: Sun, 23 Apr 2006 16:15:42 +0200
Message-ID: <200604231615.43399.ioe-lkml@rameria.de>
References: <Pine.LNX.4.44L0.0604201819040.19330-100000@lifa01.phys.au.dk> <200604211852.47335.netdev@axxeo.de> <20060422.225639.93889487.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@axxeo.de, simlo@phys.au.dk, linux-kernel@vger.kernel.org,
	mingo@elte.hu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay05.ispgateway.de ([80.67.18.43]:37064 "EHLO
	smtprelay05.ispgateway.de") by vger.kernel.org with ESMTP
	id S1751404AbWDWOSH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Apr 2006 10:18:07 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060422.225639.93889487.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

On Sunday, 23. April 2006 07:56, David S. Miller wrote:
> > If cacheline bouncing because of the shared filled_entries becomes an issue,
> > you are receiving or sending a lot.
> 
> Cacheline bouncing is the core issue being addressed by this
> data structure, so we really can't consider your idea seriously.

Ok, I can see it now more clearly. Many thanks for clearing that up 
in the other replies. I had a major misunderstanding there.

> I've just got an off-by-one error, no need to wreck the entire
> data structure just to solve that :-)

Yes, you are right. But even then I can still implement the
reserve/commit once you provide the helpers for
producer_space and consumer_space.


Regards

Ingo Oeser
