From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: fix panic if initialization fails
Date: Sat, 09 May 2009 13:20:00 -0700 (PDT)
Message-ID: <20090509.132000.242388766.davem@davemloft.net>
References: <20090508232100.GB4881@psychotron.englab.brq.redhat.com>
	<20090508233057.GQ3035@Chamillionaire.breakpoint.cc>
	<20090508233604.GD4881@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, bonding-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59840
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752920AbZEIUUE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2009 16:20:04 -0400
In-Reply-To: <20090508233604.GD4881@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Sat, 9 May 2009 01:36:04 +0200

> Sat, May 09, 2009 at 01:30:57AM CEST, fw@strlen.de wrote:
>>Jiri Pirko <jpirko@redhat.com> wrote:
>>> > err:
>>> >-	list_for_each_entry(bond, &bond_dev_list, bond_list) {
>>> >-		bond_work_cancel_all(bond);
>>> >-		destroy_workqueue(bond->wq);
>>> >-	}
>>> This looks correct.
>>> 
>>> >-
>>> >-	bond_destroy_sysfs();
>>> Why this is not here anymore? I think it should be called in this function.
>>
>>Thanks for reviewing.
>>I removed it because, if you hit this error path, sysfs registration
>>failed, so there is no entry to remove.
> 
> Yes, you are right.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied, thanks!
