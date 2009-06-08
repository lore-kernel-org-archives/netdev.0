From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: tg3 stops working when NFS is involved
Date: Mon, 8 Jun 2009 09:40:38 -0700
Message-ID: <20090608164038.GA8825@xw6200.broadcom.net>
References: <alpine.DEB.2.01.0906072115420.6439@bogon>
 <alpine.DEB.2.01.0906072215000.6439@bogon>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Matthew Carlson" <mcarlson@broadcom.com>
To: "Christian Kujau" <lists@nerdbynature.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4741 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753180AbZFHQkl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jun 2009 12:40:41 -0400
In-Reply-To: <alpine.DEB.2.01.0906072215000.6439@bogon>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 07, 2009 at 10:18:52PM -0700, Christian Kujau wrote:
> On Sun, 7 Jun 2009, Christian Kujau wrote:
> > anything else - so, I figure it's not a client problem. And I'm not sure 
> > if it's NFS problem either, because restarting the NFS server doesn't do 
> > anything, I really have to rmmod/modprobe the tg3 module. OTOH, I cannot 
> > reproduce this without NFS: running e.g. iperf (TCP, UDP) did not trigger 
> > it.
> 
> Just tested with Samba - after a few megabytes of transmitted data, tg3 stops 
> working, with no messages printed in the kernel log :-\
> 
> I don't know why iperf does not trigger it though....

Hi Christian.  This seems to be a common problem with the 5906 on some
notebooks.  The word on the street is that turning sg off through
ethtool seems to avoid the problem.  While I dig deeper into this
problem, you could try that and see if it helps you.

