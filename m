From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/4] bonding: Fix locking in 802.3ad mode
Date: Tue, 25 Mar 2008 23:18:18 -0400
Message-ID: <47E9C07A.1040208@pobox.com>
References: <12061637763004-git-send-email-fubar@us.ibm.com> <1206163777364-git-send-email-fubar@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59855 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751453AbYCZDSW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Mar 2008 23:18:22 -0400
In-Reply-To: <1206163777364-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh wrote:
> 	The 802.3ad state machine lock can be acquired in both softirq and
> not softirq context, but was not held at _bh to prevent a deadlock (which
> could occur if a LACPDU arrived and was processed while the lock was
> held).
> 
> 	Corrected this, now hold the state machine lock at _bh to prevent
> deadlock.
> 
> 	Bug reported by Todd Fleisher <todd@fleish.org>.
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
> ---
>  drivers/net/bonding/bond_3ad.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)

applied 1-4


