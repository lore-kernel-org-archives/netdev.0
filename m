From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Wed, 1 Apr 2009 19:01:03 +0200
Message-ID: <20090401170103.GU11935@one.firstfloor.org>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <87ab71monw.fsf@basil.nowhere.org> <49D35825.3050001@novell.com> <20090401132340.GT11935@one.firstfloor.org> <49D37805.1060301@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	agraf@suse.de, pmullaney@novell.com, pmorreale@novell.com,
	anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:37279 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753941AbZDAQ70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 12:59:26 -0400
Content-Disposition: inline
In-Reply-To: <49D37805.1060301@novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 01, 2009 at 10:19:49AM -0400, Gregory Haskins wrote:
> >>     
> >
> > But surely you must have some specific use case in mind? Something
> > that it does better than the various methods that are available
> > today. Or rather there must be some problem you're trying
> > to solve. I'm just not sure what that problem exactly is.
> >   
> Performance.  We are trying to create a high performance IO infrastructure.

Ok. So the goal is to bypass user space qemu completely for better
performance. Can you please put this into the initial patch
description?

> So the administrator can then set these attributes as
> desired to manipulate the configuration of the instance of the device,
> on a per device basis.

How would the guest learn of any changes in there?

I think the interesting part would be how e.g. a vnet device
would be connected to the outside interfaces.

> So the admin would instantiate this "vdisk" device and do:
> 
> 'echo /path/to/my/exported/disk.dat > /sys/vbus/devices/foo/src_path'

So it would act like a loop device? Would you reuse the loop device
or write something new?

How about VFS mount name spaces?

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
