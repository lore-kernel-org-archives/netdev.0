From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: bonding...
Date: Thu, 03 Mar 2011 09:24:25 -0800
Message-ID: <6286.1299173065@death>
References: <20110302.214910.112578818.davem@davemloft.net> <20110303114539.GB5146@hmsreliant.think-freely.org> <20110303160404.GO11864@gospo.rdu.redhat.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:41509 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758523Ab1CCRYq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 12:24:46 -0500
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p23GwcMO019832
	for <netdev@vger.kernel.org>; Thu, 3 Mar 2011 11:58:38 -0500
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 40A5538C803B
	for <netdev@vger.kernel.org>; Thu,  3 Mar 2011 12:24:44 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p23HOShJ1351722
	for <netdev@vger.kernel.org>; Thu, 3 Mar 2011 12:24:29 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p23HOSqN031245
	for <netdev@vger.kernel.org>; Thu, 3 Mar 2011 14:24:28 -0300
In-reply-to: <20110303160404.GO11864@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek <andy@greyhouse.net> wrote:

>On Thu, Mar 03, 2011 at 06:45:39AM -0500, Neil Horman wrote:
>> On Wed, Mar 02, 2011 at 09:49:10PM -0800, David Miller wrote:
>> > 
>> > Hey, if someone could step up and help with bonding maintainence
>> > in some tangible way, I'd really appreciate it.
>> > 
>> > Currently the situation is that many people work on bonding patches,
>> > and whilst I do try and wait for some ACKs to arrive, I am the person
>> > who has to sort out when changes are ready, decide to apply them, and
>> > poke for review when things fall through the cracks.
>> > 
>> > Sometimes patches go for weeks without ACKs, and in that situation
>> > I have to either try to understand the changes myself, or wait
>> > potentially forever for someone with bonding knowledge to take a
>> > good look at the patch and properly review it.
>> > 
>> > It was nearly 2 weeks before Oleg V. Ukhno's 802.3ad round-robin patch
>> > got looked at by anyone with bonding knowledge.  And it only happened
>> > because I got tired of seeing his poor patch rot in patchwork
>> > and had to explicitly asked for review the other day.
>> > 
>> > This is unacceptable, people are submitting multiple bonding patches
>> > every single day now.  It needs a clueful bonding person looking at
>> > these submissions on a constant basis.
>> > 
>> > This is a serious problem and is backlogging the netdev patch queue.
>> > 
>> > So if someone would become an active bonding patch-accumulator, and
>> > send me sets of patches that are ready to apply, I would really
>> > appreciate it.
>> > 
>> > Thanks.
>> I nominate gospo.  If he doesn't want to, I can do it
>> Neil
>> 
>
>I would be willing to do it, but my one of my goals would be to prevent
>some of the feature creep we are currently seeing with bonding (as Ben
>has suggested).  That doesn't mean I want to stop all new features, but
>at this point things are starting to get out of control. I suspect this
>is why Jay has struggled to keep up with the patches.

	My main problem keeping up at the moment is another demand on my
time that should run its course in a couple of weeks.  My time for
community activity is somewhat limited until then.

	As far as the features go, yes, I agree that things are getting
out of hand.  The two pending patches for special cases related to
802.3ad (Oleg's patch to permit round robining, the other to enable
spanning aggregators across switches), for example, are fine
functionality, but there really needs to be a better, generic, way to do
this sort of niche case activity without adding more knobs.

	I personally like Stephen's suggestion to hook bonding into a
netfilter gadget, similar to ebtables for bridge.  Done properly, such a
gadget should handle (or be extended to handle) the niche cases that
right now end up as new knobs in the driver.

>I would also want to look at a restructuring of the configuration.  The
>lines are starting to blur between some of the modes and output port
>selection for other modes and that needs to be cleared up.

	What did you have in mind here?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
