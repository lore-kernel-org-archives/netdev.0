From: Emese Revfy <re.emese@gmail.com>
Subject: Re: [PATCH 1/1] Constify struct sysfs_ops for v2.6.33-rc4
Date: Sun, 17 Jan 2010 21:15:59 +0100
Message-ID: <4B536FFF.9060509@gmail.com>
References: <4B5338D6.2050209@gmail.com> <20100117182537.GQ19799@ZenIV.linux.org.uk> <20100117182906.GR19799@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, teigland@redhat.com,
	Matt_Domsch@dell.com, maciej.sosnowski@intel.com,
	hjk@linutronix.de, Pekka Enberg <penberg@cs.helsinki.fi>,
	jens.axboe@oracle.com, shemminger@vyatta.com,
	akpm@linux-foundation.org, davem@davemloft.net,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	Greg KH <gregkh@suse.de>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:34284 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750922Ab0AQUO0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Jan 2010 15:14:26 -0500
In-Reply-To: <20100117182906.GR19799@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Al Viro wrote:
> On Sun, Jan 17, 2010 at 06:25:37PM +0000, Al Viro wrote:
>> On Sun, Jan 17, 2010 at 05:20:38PM +0100, Emese Revfy wrote:
>>
>>> Signed-off-by: Emese Revfy <re.emese@gmail.com>
>>> Acked-by: David Teigland <teigland@redhat.com>
>>> Acked-by: Matt Domsch <Matt_Domsch@dell.com>
>>> Acked-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
>>> Acked-by: Hans J. Koch <hjk@linutronix.de>
>>> Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>
>>> Acked-by: Jens Axboe <jens.axboe@oracle.com>
>>> Acked-by: Stephen Hemminger <shemminger@vyatta.com>
>> NACKed-by: Al Viro <viro@zeniv.linux.org.uk>
>>
>> Same reason.
> 
> BTW, commit 9905a43b2d563e6f89e4c63c4278ada03f2ebb14
> Author: Emese Revfy <re.emese@gmail.com>
> Date:   Mon Dec 14 00:58:57 2009 +0100
> 
>     backlight: Constify struct backlight_ops
> 
> is also crap; again, same reason.  Would you please get a clue and stop
> pushing that particular bullshit into the tree?

The backlight maintainer accepted that patch before the discussion
on field constification concluded.
I drew his attention to the discussion (http://lkml.org/lkml/2009/12/16/395)
but he still accepted the patch as is.
--
Emese
