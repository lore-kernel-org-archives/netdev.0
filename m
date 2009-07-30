From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] eexpress: Read buffer overflow
Date: Thu, 30 Jul 2009 13:28:25 -0700 (PDT)
Message-ID: <20090730.132825.03094033.davem@davemloft.net>
References: <20090729122953.GC5490@ff.dom.local>
	<4A704C40.1070606@gmail.com>
	<20090729200517.GB3058@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roel.kluin@gmail.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45249
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752709AbZG3U2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 16:28:17 -0400
In-Reply-To: <20090729200517.GB3058@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Wed, 29 Jul 2009 22:05:17 +0200

> On Wed, Jul 29, 2009 at 03:18:56PM +0200, Roel Kluin wrote:
>> start_code is 69 words, but the code always writes a multiple of 16 words,
>> so the last 11 words written are outside the array.
>> 
>> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
>> ---
>> > Now you seem to make my previous math working :-)
>> > 
>> >>> (max) i = 64, (max) j = 14, (64+14+16)/2 = 47 < 69, so it seems to copy
>> >>> less than its size?
>> > 
>> > Jarek P.
>> > 
>> 
>> You're right, thanks for reviewing, this one should be correct.
> 
> Looks OK to me.

Applied.

