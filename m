From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] tcp: Wrong timeout for SYN segments
Date: Thu, 23 Aug 2012 14:15:23 +0200
Message-ID: <1345724123.5904.756.camel@edumazet-glaptop>
References: <503419D3.1080700@linlab.net>
	 <CAFbMe2M7ekc94bQk7vTS1LhScPd49VZ-zKOCUXhqwxXtL-nkuA@mail.gmail.com>
	 <50361AEA.6010807@linlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "H.K. Jerry Chu" <hkjerry.chu@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alex Bergmann <alex@linlab.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:64768 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933837Ab2HWMP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 08:15:28 -0400
In-Reply-To: <50361AEA.6010807@linlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-08-23 at 13:58 +0200, Alex Bergmann wrote:
> On 08/22/2012 06:41 PM, H.K. Jerry Chu wrote:

> > This issue occurred to me right after I submitted the patch for RFC6298.
> > I did not commit any more change because RFC compliance aside, 180secs
> > just seem like eternity in the Internet age.
> >
> > (See my past post on this at
> > http://marc.info/?l=linux-netdev&m=130759078118866&w=2)
> 
> Okay, I missed that post during my search about the current situation.

I would suggest to increase TCP_SYN_RETRIES from 5 to 6.

180 secs is eternity, but 31 secs is too small.

Can you repost a v2, only changing TCP_SYN_RETRIES ?
