From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH for-next V7 00/10] Move RoCE GID management to IB/Core
Date: Fri, 31 Jul 2015 16:01:02 -0600
Message-ID: <20150731220102.GA31209@obsidianresearch.com>
References: <1438270411-17648-1-git-send-email-matanb@mellanox.com>
 <CAJ3xEMh9z=LG7dW0nBP8Zdrbf0SkZ_GCxjCoowWXuw2dueN+xg@mail.gmail.com>
 <55BB6F10.5030408@redhat.com>
 <20150731163201.GA6027@obsidianresearch.com>
 <55BBB353.7020806@redhat.com>
 <CAJ3xEMiP57qf58B=VHRazs50RC5r-7OsUPb=GV1kBQ6vu6Tqjw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Ledford <dledford@redhat.com>,
	Matan Barak <matanb@mellanox.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	Sean Hefty <sean.hefty@intel.com>,
	Somnath Kotur <Somnath.Kotur@avagotech.com>,
	Moni Shoua <monis@mellanox.com>,
	"talal@mellanox.com" <talal@mellanox.com>,
	Haggai Eran <haggaie@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:37330 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751272AbbGaWBM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Jul 2015 18:01:12 -0400
Content-Disposition: inline
In-Reply-To: <CAJ3xEMiP57qf58B=VHRazs50RC5r-7OsUPb=GV1kBQ6vu6Tqjw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 01, 2015 at 12:24:23AM +0300, Or Gerlitz wrote:

> addressed in incremental patch, as Doug suggested. Jason, it's wrong
> to send developers again and again to fix things which were 
> perfect in Vn-1 but also not being covered by reviewers on Vn-1, at
> some point the reviewer can't load new comments which gate the

I don't even know what you are talking about Or.

v6 had some small problems in the logic and v7 introduces a fairly
serious flaw while trying to fix them. IMHO, you are better to merge
v6 than v7, at least v6's problems are less likely to be serious.

IMHO, it took until around v5/v6 before this series was even worth
taking a detailed look at. I'm certainly not willing to waste my time
doing detailed reviews on other elements when basic things like
locking and refcounting are screwed up.

I think you are really off side with the idea that a review has to see
every problem in Vn or ignore it in Vn+1. That is obviously
unworkable.

> acceptance but rather be willing for things to be fixed incrementally.

That is the same argument you used for the timestamp _ex UAPI mess,
last cycle, where are the incremental fixes for that?

Jason
