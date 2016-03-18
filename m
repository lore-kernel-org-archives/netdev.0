From: Luis de Bethencourt <luisbg@osg.samsung.com>
Subject: Re: [PATCH] mac80211: fix order of flag descriptions
Date: Fri, 18 Mar 2016 17:49:36 +0000
Message-ID: <56EC3FB0.8020006@osg.samsung.com>
References: <1458317369-28185-1-git-send-email-luisbg@osg.samsung.com> <1458318955-32070-1-git-send-email-luisbg@osg.samsung.com> <1458322179.26915.2.camel@perches.com> <56EC3DA6.2090105@osg.samsung.com> <1458323163.26915.8.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, davem@davemloft.net,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.s-osg.org ([54.187.51.154]:54697 "EHLO lists.s-osg.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757627AbcCRRtk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Mar 2016 13:49:40 -0400
In-Reply-To: <1458323163.26915.8.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/03/16 17:46, Joe Perches wrote:
> On Fri, 2016-03-18 at 17:40 +0000, Luis de Bethencourt wrote:
>> On 18/03/16 17:29, Joe Perches wrote:
>>> On Fri, 2016-03-18 at 16:35 +0000, Luis de Bethencourt wrote:
>>>> Fix order of mac80211_rx_flags description to match the enum.
> []
>>>> I want ahead and fixed the order of the descriptions. checkpatch.pl was giving
>>>> a warning to my previous patch and I had a hunch it was because the wrong order
>>>> breaks the parser. Indeed it does and with this patch below checkpatch.pl does
>>>> not complain about this flag descriptions anymore.
>>> checkpatch complains?  About what?
>> warning: Enum value 'RX_FLAG_DUP_VALIDATED' not described in enum 'mac80211_rx_flags'
> 
> That's not a checkpatch warning.
> 
> cheers, Joe
> 

Oh no!

Joe is right. That isn't a checkpatch warning, but checkpatch just printing the line
in my commit message that goes over 75 characters. Which I kept that big to keep the
format from make htmldocs.

I still think the order of the documentation should match the enum regardless, it is
nicer for developers reading the code.

Sorry :( my bad for misinterpreting checkpatch's output.

Thanks you Joe for correcting me,
Luis 
