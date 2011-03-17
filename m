From: David Miller <davem@davemloft.net>
Subject: Re: No iproute2 for 2.6.38
Date: Thu, 17 Mar 2011 08:12:28 -0700 (PDT)
Message-ID: <20110317.081228.226779291.davem@davemloft.net>
References: <4D804EBD.4030904@us.ibm.com>
	<20110316170441.351efba7@nehalam>
	<20110317141455.GE1724@khazad-dum.debian.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, sri@us.ibm.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: hmh@hmh.eng.br
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55597
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753426Ab1CQPLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2011 11:11:50 -0400
In-Reply-To: <20110317141455.GE1724@khazad-dum.debian.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Date: Thu, 17 Mar 2011 11:14:55 -0300

> On Wed, 16 Mar 2011, Stephen Hemminger wrote:
>> > 2.6.38 includes support for macvlan/macvtap 'passthru' mode that allows 
>> > assigning
>> > SR-IOV VFs to a KVM guest via macvtap/virtio.
>> > It is not possible to support live migration using direct assignment of 
>> > VF's to a guest,
>> > but 'passthu' assignment makes this possible.
>> > 
>> > Enabling this feature requires the following patch to iproute2 that 
>> > allows creating macvlan
>> > device in 'passthru' mode.
>> >      http://patchwork.ozlabs.org/patch/69515/
>> > Looks like this patch is still marked as 'Awaiting upstream'.
>> > 
>> > Could you apply this patch and it would be great if a version of 
>> > iproute2 is released for 2.6.38.
>> 
>> Sorry missed it applied to repository, still not sure worth a new release.
> 
> Release early, release often.  And someone actually bothered asking you to
> specifically, so it clearly is going to be useful to that someone.
> 
> So, why not do a 2.6.38 release?

Indeed, Stephen please make a release.
