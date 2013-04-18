From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH repost for-3.9] pci: avoid work_on_cpu for nested SRIOV probes
Date: Thu, 18 Apr 2013 21:41:31 +0300
Message-ID: <CAJZOPZLuT7jcUJi_EEQ1_fgVCuFHk1Xzbb6kQtPSS4LfL=ArVg@mail.gmail.com>
References: <20130411185853.GE23301@redhat.com>
	<20130411190408.GM17641@mtj.dyndns.org>
	<20130411191717.GB25515@redhat.com>
	<20130411192005.GN17641@mtj.dyndns.org>
	<20130411203053.GC25515@redhat.com>
	<20130411204104.GC11956@mtj.dyndns.org>
	<516AA80F.7040505@mellanox.com>
	<20130414134339.GA3050@htj.dyndns.org>
	<20130418083347.GA16526@redhat.com>
	<517007F0.4060000@mellanox.com>
	<20130418135458.GC20862@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <ogerlitz@mellanox.com>, Tejun Heo <tj@kernel.org>,
	Ming Lei <ming.lei@canonical.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	Roland Dreier <roland@kernel.org>,
	netdev <netdev@vger.kernel.org>, Yan Burman <yanb@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f51.google.com ([209.85.128.51]:39256 "EHLO
	mail-qe0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751153Ab3DRSlb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 14:41:31 -0400
In-Reply-To: <20130418135458.GC20862@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 18, 2013 at 4:54 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
[...]
> Tejun, what do you say my patch is used for 3.9, and we can revisit for 3.10.
> The release is almost here. If yes please send your Ack.

Michael,

I assume you mean pull to 3.9 both Tejun's and your patch, correct? I
wasn't sure what does this really buys us... we got read from the
false-positive lockdep warning which takes place during nested probe
and got another lockdep warning during the probe of Interrupt
controller

Or.
