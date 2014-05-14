From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: [Xen-devel] [PATCH V8 net-next 0/6] xen-net{back, front}: Multiple transmit and receive queues
Date: Wed, 14 May 2014 23:36:41 +0200
Message-ID: <13110116486.20140514233641@eikelenboom.it>
References: <1400075550-4580-1-git-send-email-andrew.bennieston@citrix.com> <526369072.20140514160923@eikelenboom.it> <20140514141347.GR6332@zion.uk.xensource.com> <53739757.5060905@citrix.com> <1296806729.20140514203719@eikelenboom.it> <20140514212432.GA30413@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Andrew Bennieston <andrew.bennieston@citrix.com>,
	<xen-devel@lists.xenproject.org>, <davem@davemloft.net>,
	<ian.campbell@citrix.com>, <netdev@vger.kernel.org>,
	<paul.durrant@citrix.com>, <david.vrabel@citrix.com>,
	<zoltan.kiss@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vserver.eikelenboom.it ([84.200.39.61]:47654 "EHLO
	smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752197AbaENVgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 17:36:46 -0400
In-Reply-To: <20140514212432.GA30413@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Wednesday, May 14, 2014, 11:24:32 PM, you wrote:

> On Wed, May 14, 2014 at 08:37:19PM +0200, Sander Eikelenboom wrote:
> [...]
>> 
>> Got the patches from the thread .. but as i expected they interfere with 
>> Zoltan's v3 fix for 3.15.
>> 

> This series targets net-next tree while Zoltan's fix targets net tree,
> but I can see the possibility they clash with each other.

This series applies fine to 3.15-rc5, it only clashes with Zoltan's v3 fixup 
patch.

> In any case the fix in this series for the bug you found is orthogonal
> to Zoltan's fix, as I understand it that bug was in the setup / teardown
> path, so you can at the very least verify this series doesn't have
> that bug anymore.

Yes but testing with a subsystem that has a known bug corrupting packets seems a 
bit moot, since i'm not certain of merging the two the right way either .. i 
suppose my testing has to wait until the next merge window then.

> Wei.

>> > - Andrew
>> >>
>> >>> --
>> >>> Sander
>> >>>
>> >>>> --
>> >>>> Andrew J. Bennieston
>> >>>
>> >>>
>> 
>> 
