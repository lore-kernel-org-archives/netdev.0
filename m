From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: Netlink messages without NLM_F_REQUEST flag
Date: Wed, 7 Jun 2017 12:35:11 -0600
Message-ID: <20170607183511.GA10225@obsidianresearch.com>
References: <20170607161901.GD1127@mtr-leonro.local>
 <20170607163758.GA25313@obsidianresearch.com>
 <CALq1K=Jj_jJ5_OAiiws-es37tFEsLeLJeSvnU+bfwd0KLkGM3Q@mail.gmail.com>
 <20170607164750.GA7507@obsidianresearch.com>
 <20170607170037.GG1127@mtr-leonro.local>
 <20170607170702.GB7507@obsidianresearch.com>
 <20170607181810.GI1127@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kaike Wan <kaike.wan@intel.com>, John Fleck <john.fleck@intel.com>,
        Ira Weiny <ira.weiny@intel.com>, Thomas Graf <tgraf@suug.ch>,
        Doug Ledford <dledford@redhat.com>,
        Jiri Pirko <jiri@mellanox.com>,
        RDMA mailing list <linux-rdma@vger.kernel.org>,
        linux-netdev <netdev@vger.kernel.org>
To: Leon Romanovsky <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:42126 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751849AbdFGSfX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Jun 2017 14:35:23 -0400
Content-Disposition: inline
In-Reply-To: <20170607181810.GI1127@mtr-leonro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 07, 2017 at 09:18:10PM +0300, Leon Romanovsky wrote:

> > AFAIK, that is different, that is acking and retriggering a single shot
> > notification, not completing a kernel initiated handshake.
> 
> It is acking that message from user was received by kernel and now
> processing.

But isn't what is cared about here - the SA thing needs to send a
request to user space and collect a reply, it runs the protocol
backwards from normal.

It is not a notification because the request actually needs a reply,
and ACK's don't help because the reply has content.

It does not use the NOTIFICATION/REQUEST/REPLY sequence because it
does not care about reliability of delivering the REQUEST to user
space.

Jason
