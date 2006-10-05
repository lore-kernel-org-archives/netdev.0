From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re:
Date: Thu, 05 Oct 2006 07:03:10 -0400
Message-ID: <4524E66E.20502@pobox.com>
References: <200609300628.k8U6SgZt030638@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:5853 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751677AbWJELDN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2006 07:03:13 -0400
To: Jay Vosburgh <fubar@us.ibm.com>
In-Reply-To: <200609300628.k8U6SgZt030638@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
> From: Karsten Keil <kkeil@suse.de>
> 
> In bond_alb_monitor the bond->curr_slave_lock write lock is taken
> and then dev_set_promiscuity maybe called which can take some time,
> depending on the network HW. If a network IRQ for this card come in
> the softirq handler maybe try to deliver more packets which end up in
> a request to the read lock of bond->curr_slave_lock -> deadlock.
> This issue was found by a test lab during network stress tests, this patch
> disable the softirq handler for this case and solved the issue.
> 
> Signed-off-by: Karsten Keil <kkeil@suse.de>
> Acked-by: Jay Vosburgh <fubar@us.ibm.com>

applied, though note that your email was slightly corrupted.  It 
included _two_ Subject headers, making the email non-compliant with RFC822.

	Jeff



