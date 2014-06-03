From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH 3.14-stable] net/mlx4_core: Preserve pci_dev_data after __mlx4_remove_one()
Date: Tue, 3 Jun 2014 11:43:05 +0300
Message-ID: <CAJZOPZJLwJrsEDMeJVmdJ3ykJWQJjSthYOTCPCrWOTws-Wta-Q@mail.gmail.com>
References: <1401607475-8367-1-git-send-email-weiyang@linux.vnet.ibm.com>
	<20140601073853.GA8635@richard>
	<538AF2CB.20603@mellanox.com>
	<20140602135334.GA28523@richard>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: Wei Yang <weiyang@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:56055 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751679AbaFCInG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 04:43:06 -0400
Received: by mail-qg0-f52.google.com with SMTP id a108so12866300qge.11
        for <netdev@vger.kernel.org>; Tue, 03 Jun 2014 01:43:05 -0700 (PDT)
In-Reply-To: <20140602135334.GA28523@richard>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 2, 2014 at 4:53 PM, Wei Yang <weiyang@linux.vnet.ibm.com> >

> Thanks for your notification, I saw your patch to fix this issue.
> Sorry for bringing a bug in the driver and thanks for your test :-)

sure

> Hmm... actually I don't understand how you trigger this crash?

1. load the driver with num_vfs = (say) four and probe_vf (say) = two
2. reboot

[...]

> Last but not the least, based on the fix you have submitted, the porting here
> is correct. My suggestion is after your fix is merged, you could do the
> porting to those version too.

As I wrote in the other thread to Bjorn, we're practically OOO for the
rest of this week, and anyway, I suggest we 1st see what ends up
happening with the fix to the regression introduced by your commit and
take it from there.
