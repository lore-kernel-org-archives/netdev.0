From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 0/4] atlx: add atl2 support
Date: Sun, 14 Sep 2008 23:21:02 -0400
Message-ID: <20080915032102.GB3028@havoc.gtf.org>
References: <20080909061247.GA17834@file.rdu.redhat.com> <48CC1718.50508@garzik.org> <48CD8CB2.2080406@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, atl2-test@lists.sourceforge.net,
	jcliburn@gmail.com
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:42599 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753597AbYIODVE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Sep 2008 23:21:04 -0400
Content-Disposition: inline
In-Reply-To: <48CD8CB2.2080406@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 14, 2008 at 06:14:10PM -0400, Chris Snook wrote:
> Jeff Garzik wrote:
>> Chris Snook wrote:
>>> This patchset adds support for atl2 hardware to the atlx codebase.  It is
>>> functionally very similar to the out-of-tree 2.0.4 version that many  
>>> distros
>>> have been shipping for a few months, though it adds a fix from 
>>> Atheros to fix
>>> the problem of device resets under heavy bidirectional load.
>>>
>>> The code needs a lot of janitorial work, and there's a lot of  
>>> low-hanging fruit
>>> for merging similar atl1 code into the shared atlx code, but I think  
>>> that work
>>> will go much faster once this is in-tree.  The driver is known to 
>>> work well for
>>> laptop and desktop use.  The only major bugs are device 
>>> initialization problems
>>> that manifest themselves immediately and obviously (the NIC doesn't  
>>> work) with
>>> certain motherboards.
>>>
>>> Please consider this for the 2.6.28 merge window.
>>>
>>> -- Chris
>>>
>>>  drivers/net/Kconfig       |   17
>>>  drivers/net/Makefile      |    1
>>>  drivers/net/atlx/Makefile |    1
>>>  drivers/net/atlx/atl2.c   | 3101  
>>> ++++++++++++++++++++++++++++++++++++++++++++++
>>>  drivers/net/atlx/atl2.h   |  482 +++++++
>>>  include/linux/pci_ids.h   |    1
>>>  6 files changed, 3600 insertions(+), 3 deletions(-)
>>
>> Send as one big patch, please?
>>
>>
>
> It's too big for vger as one patch.  There's a lot of code that can be 
> whittled down, but this driver has been delayed for months already 
> waiting for that to be finished.  Would you prefer a gzipped One Big 
> Patch?

_I_ need it in standard patch format, as one big patch.  No MIME
encoding, no gzip, no URLs, just a patch like any other.

	Jeff



