From: Jonathan Nieder <jrnieder@gmail.com>
Subject: Re: [PATCH 2.6.32.y] netxen: support for GbE port settings
Date: Mon, 12 Mar 2012 04:40:39 -0500
Message-ID: <20120312093919.GA17642@burratino>
References: <1300172175-16853-1-git-send-email-amit.salecha@qlogic.com>
 <20120312043539.GA15903@burratino>
 <20120312090950.GC11569@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	stable@vger.kernel.org, Sony Chacko <sony.chacko@qlogic.com>,
	Ana Guerrero <ana@debian.org>,
	Michael Mastrogiacomo <mmastrogiacomo@ultralogistics.com>,
	Amit Kumar Salecha <amit.salecha@qlogic.com>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:37449 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754902Ab2CLJkw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2012 05:40:52 -0400
Content-Disposition: inline
In-Reply-To: <20120312090950.GC11569@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Willy,

Willy Tarreau wrote:
> On Sun, Mar 11, 2012 at 11:35:39PM -0500, Jonathan Nieder wrote:

>> From: Sony Chacko <sony.chacko@qlogic.com>
>> Date: Tue, 15 Mar 2011 14:54:55 -0700
>>
>> commit bfd823bd74333615783d8108889814c6d82f2ab0 upstream.
[...]
> One very important requirement for merging such a
> fix is that it is already present in more recent stable releases :
> when users upgrade from 2.6.32 to 3.0, we don't want them to get
> the bug again.

Thanks for explaining.  To answer this question: since the patch
(v2.6.39-rc1~468^2~23) was in mainline in 2.6.39, it gets the
privilege of inclusion in 3.0.y by default.

> If this requirement is satisfied and David is not opposed to merging
> the patch, then we can include it (even in this release, considering
> the authors and reviewers are already CC'd).

Cheers,
Jonathan
