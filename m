From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH v4 for-next 00/12] Add network namespace support in the
 RDMA-CM
Date: Thu, 4 Jun 2015 10:06:08 -0600
Message-ID: <20150604160608.GA27699@obsidianresearch.com>
References: <1432837360.114391.35.camel@redhat.com>
 <CAJ3xEMh2T5-56rFxWVdct2uAZYW1ZrKivWfS45V-mvhAfwyGaA@mail.gmail.com>
 <1432850150.114391.56.camel@redhat.com>
 <556ED0D5.8010502@mellanox.com>
 <20150603161447.GC12073@obsidianresearch.com>
 <CAJ3xEMjM53sYuEgQV3WPaN4WErk_YcojPY2zBcmq-+3W2dfD+A@mail.gmail.com>
 <20150603195325.GC7902@obsidianresearch.com>
 <CAJ3xEMiO+hEzOJ2oJ5G-mmBeaX4ZHvUyhNSAzsrRDui6dFjvCg@mail.gmail.com>
 <20150603214508.GA14968@obsidianresearch.com>
 <55701D4D.20307@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	Doug Ledford <dledford@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>
To: Haggai Eran <haggaie@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:53498 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751660AbbFDQGO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jun 2015 12:06:14 -0400
Content-Disposition: inline
In-Reply-To: <55701D4D.20307@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 04, 2015 at 12:41:33PM +0300, Haggai Eran wrote:
> On 04/06/2015 00:45, Jason Gunthorpe wrote:

> > I don't know if that is a good idea, an unstable SLAAC is not in
> > spirit with the RFCs. The safest bet is to return error and disable
> > SLAAC completely.

> Maybe this is a silly question, but doesn't DAD already disable SLAAC
> addresses when there's a conflict?

Yes, DAD should certainly trigger and disable the child, but the
kernel should not rely on DAD for correctness, it is a safety net, and
it isn't guarenteed 100% reliable.

Jason
