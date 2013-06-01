From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: Re: [PATCH v2 net 0/6] net/core, bonding: dev_uc_sync fixes, bonding
 update
Date: Sat, 1 Jun 2013 14:04:11 -0500
Message-ID: <20130601190411.GA13515@lintop.rgmadvisors.com>
References: <1370037451-29466-1-git-send-email-fubar@us.ibm.com>
 <CAJZOPZJ8onm0NhKMbQFmZFcoVzVZ=okikLzk=8rWrDvYGrL1Cw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f178.google.com ([209.85.216.178]:48131 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753831Ab3FATEW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jun 2013 15:04:22 -0400
Received: by mail-qc0-f178.google.com with SMTP id l11so1438057qcy.37
        for <netdev@vger.kernel.org>; Sat, 01 Jun 2013 12:04:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJZOPZJ8onm0NhKMbQFmZFcoVzVZ=okikLzk=8rWrDvYGrL1Cw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 01, 2013 at 08:00:04PM +0300, Or Gerlitz wrote:
> On Sat, Jun 1, 2013 at 12:57 AM, Jay Vosburgh <fubar@us.ibm.com> wrote:
> > This patch set includes 6 patches: four fixes to the dev_mc_sync /  dev_mc_unsync
> >system; and two patches to bonding, one to utilize the sync / unsync functions
> 
> does anything here needs to go into -stable, or it was all introduced
> in 3.10-rc1?

The commit that broke things for me was introduced in 3.10-rc1:

$ git describe --contains 4cd729b04285b7330edaf5a7080aa795d6d15ff3
v3.10-rc1~66^2~128^2~1

--
Shawn
