From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Re: atl1 driver corrupting memory?
Date: Wed, 25 Jul 2007 19:24:22 -0500
Message-ID: <20070725192422.47c7c476@osprey.hogchain.net>
References: <46A79790.6050203@redhat.com>
	<46A7BEF9.1000600@redhat.com>
	<46A7C116.4010900@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Chris Snook <csnook@redhat.com>, Netdev <netdev@vger.kernel.org>,
	jeff@garzik.org, Huang Xiong <xiong.huang@atheros.com>
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf20aec.mail.bellsouth.net ([205.152.59.68]:58188 "EHLO
	imf20aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751745AbXGZAYZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2007 20:24:25 -0400
Received: from ibm64aec.bellsouth.net ([70.144.215.67])
          by imf20aec.mail.bellsouth.net with ESMTP
          id <20070726002424.GTLZ8519.imf20aec.mail.bellsouth.net@ibm64aec.bellsouth.net>
          for <netdev@vger.kernel.org>; Wed, 25 Jul 2007 20:24:24 -0400
In-Reply-To: <46A7C116.4010900@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 25 Jul 2007 17:31:02 -0400
Chuck Ebbert <cebbert@redhat.com> wrote:

> This is what was committed.
> 
> http://git.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=3f516c00d416bd39aab6cfb348b68919e295fe23
> http://git.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=ef76e3e2505db01f7d4b537854f4a177220c26c8

I'm doubtful these patches will fix the highmem corruption problem
we've seen in the L1.  I actually extracted the changes in the
referenced commits from the vendor's current out-of-tree driver, and
unfortunately he was able to duplicate the problem in his lab using
that driver.

As a workaround, Chuck, your reporter can boot with mem=3900 until the
problem is resolved.

I go on record with Chris:  we should apply the patch at
http://lkml.org/lkml/2007/6/25/293 until we get to the bottom of it.
The patch is in Jeff's queue, but I think he suspects a driver bug and
so far hasn't chosen to apply the patch.

Jeff, can we ask you to please reconsider?

Jay
