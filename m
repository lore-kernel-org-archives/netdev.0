From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH repost for-3.9] pci: avoid work_on_cpu for nested SRIOV
 probes
Date: Thu, 11 Apr 2013 12:04:08 -0700
Message-ID: <20130411190408.GM17641@mtj.dyndns.org>
References: <20130411153030.GA22743@redhat.com>
 <20130411180517.GJ17641@mtj.dyndns.org>
 <20130411185853.GE23301@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Ming Lei <ming.lei@canonical.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	Roland Dreier <roland@kernel.org>,
	netdev <netdev@vger.kernel.org>, Yan Burman <yanb@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:38595 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750731Ab3DKTEO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 15:04:14 -0400
Content-Disposition: inline
In-Reply-To: <20130411185853.GE23301@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey,

On Thu, Apr 11, 2013 at 09:58:54PM +0300, Michael S. Tsirkin wrote:
> > Hmm... how about adding a work_on_cpu_nested() which takes @subclass
> > argument?  Wouldn't that be much cleaner?
> > 
> > Thanks.
> 
> Is that 3.9 material though?

Why wouldn't it be?  It's actually safer as it doesn't change any
logic.  It's just updating lockdep annotation, which is what's needed
here anyway.

Thanks.

-- 
tejun
