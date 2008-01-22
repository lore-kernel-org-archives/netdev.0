From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] bluetooth : move children of connection device to NULL
	before connection down
Date: Tue, 22 Jan 2008 07:18:16 +0100
Message-ID: <1200982696.7978.148.camel@aeonflux>
References: <20080121044913.GA4162@darkstar.te-china.tietoenator.com>
	 <20080121045401.GB4162@darkstar.te-china.tietoenator.com>
	 <20080121.031417.171098597.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: hidave.darkstar@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bluez-devel@lists.sourceforge.net,
	cornelia.huck@de.ibm.com, gombasg@sztaki.hu, htejun@gmail.com,
	viro@zeniv.linux.org.uk, kay.sievers@vrfy.org, greg@kroah.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:48926 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751829AbYAVGTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 01:19:17 -0500
In-Reply-To: <20080121.031417.171098597.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

> > Add people missed in cc-list.
> 
> Thanks Dave for your continued efforts on Bluetooth bugs like this.
> 
> Marcel, are you going to review/ACK/integrate/push-upstream/whatever
> any of these Bluetooth patches?
> 
> It hasn't been getting much love from you as of late, you are one of
> the listed maintainers, and I don't want to lose any of Dave's
> valuable bug fixing work.

I will be fully back in business next week. Just got stuck in a project
that needed 200% of my time to get it going.

> Or should I just handle it all directly?

I followed the list only a little bit, but from what I have seen is that
Dave is doing a great job in tracking all issues down to the real cause.

I had a look at his last patch and after review, I agree that this is a
possible solution. I only have two nitpicks about the coding style. So
in del_conn the struct device declaration should be made after the
struct hci_conn assignment from the container and I would put an extra
empty line before the devel_del, put_device block. Nitpicks only.

Right now I can't think of any side effects by this patch. Actually I
only see an improvement with this patch. So please take it directly and
starting with next week, I gonna make sure that they are handled again
properly by me.

Regards

Marcel


