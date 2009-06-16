From: David Miller <davem@davemloft.net>
Subject: Re: net: fix network drivers ndo_start_xmit() return values
Date: Tue, 16 Jun 2009 02:22:41 -0700 (PDT)
Message-ID: <20090616.022241.47960267.davem@davemloft.net>
References: <4A367E14.4040104@trash.net>
	<20090616061603.GA4494@ff.dom.local>
	<20090616071204.GB4494@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, perex@perex.cz
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40477
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752547AbZFPJWi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 05:22:38 -0400
In-Reply-To: <20090616071204.GB4494@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Tue, 16 Jun 2009 07:12:04 +0000

> On Tue, Jun 16, 2009 at 06:16:03AM +0000, Jarek Poplawski wrote:
>> On 15-06-2009 19:00, Patrick McHardy wrote:
>> > This patch contains the final driver ndo_start_xmit() return
>> > value fixups. I'm pretty sure I got them all ...
> 
> ...You should probably revisit wireless/zd1201.c (return 0) btw.

Yes this patch needs a little bit more work :)
