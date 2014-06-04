From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH 3.14-stable] net/mlx4_core: Preserve pci_dev_data after
 __mlx4_remove_one()
Date: Wed, 4 Jun 2014 09:44:19 +0800
Message-ID: <20140604014419.GA8817@richard>
References: <1401607475-8367-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <20140601073853.GA8635@richard>
 <538AF2CB.20603@mellanox.com>
 <20140602135334.GA28523@richard>
 <CAJZOPZJLwJrsEDMeJVmdJ3ykJWQJjSthYOTCPCrWOTws-Wta-Q@mail.gmail.com>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp04.au.ibm.com ([202.81.31.146]:36117 "EHLO
	e23smtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752408AbaFDBo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 21:44:29 -0400
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Wed, 4 Jun 2014 11:44:26 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 9E93C2BB0054
	for <netdev@vger.kernel.org>; Wed,  4 Jun 2014 11:44:22 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s541MT3f57212942
	for <netdev@vger.kernel.org>; Wed, 4 Jun 2014 11:22:30 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s541iKvc026370
	for <netdev@vger.kernel.org>; Wed, 4 Jun 2014 11:44:21 +1000
Content-Disposition: inline
In-Reply-To: <CAJZOPZJLwJrsEDMeJVmdJ3ykJWQJjSthYOTCPCrWOTws-Wta-Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2014 at 11:43:05AM +0300, Or Gerlitz wrote:
>On Mon, Jun 2, 2014 at 4:53 PM, Wei Yang <weiyang@linux.vnet.ibm.com> >
>
>> Thanks for your notification, I saw your patch to fix this issue.
>> Sorry for bringing a bug in the driver and thanks for your test :-)
>
>sure
>
>> Hmm... actually I don't understand how you trigger this crash?
>
>1. load the driver with num_vfs = (say) four and probe_vf (say) = two
>2. reboot
>

Thanks, I would do some tests to see why this happens.

>[...]
>
>> Last but not the least, based on the fix you have submitted, the porting here
>> is correct. My suggestion is after your fix is merged, you could do the
>> porting to those version too.
>
>As I wrote in the other thread to Bjorn, we're practically OOO for the
>rest of this week, and anyway, I suggest we 1st see what ends up
>happening with the fix to the regression introduced by your commit and
>take it from there.

Sure :-)

-- 
Richard Yang
Help you, Help me
