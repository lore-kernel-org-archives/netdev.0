From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH] net/mlx4_core: Preserve pci_dev_data after
 __mlx4_remove_one()
Date: Wed, 28 May 2014 09:48:48 +0800
Message-ID: <20140528014848.GB5830@richard>
References: <20140527.145403.1114311769956769966.davem@davemloft.net>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: weiyang@linux.vnet.ibm.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp02.au.ibm.com ([202.81.31.144]:44740 "EHLO
	e23smtp02.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751966AbaE1Bs4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 21:48:56 -0400
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Wed, 28 May 2014 11:48:54 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 44E6D2BB0058
	for <netdev@vger.kernel.org>; Wed, 28 May 2014 11:48:50 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s4S1mYWt10617162
	for <netdev@vger.kernel.org>; Wed, 28 May 2014 11:48:34 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s4S1mnZ2016421
	for <netdev@vger.kernel.org>; Wed, 28 May 2014 11:48:49 +1000
Content-Disposition: inline
In-Reply-To: <20140527.145403.1114311769956769966.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 27, 2014 at 02:54:03PM -0400, David Miller wrote:
>
>If you want me to add this to -stable, you'll have to do the backporting
>for me as this change doesn't come anywhere near to applying to v3.14.4

David,

Yep, I am willing to do this.

I haven't done some backporting job before, so not sure how to and which
attention I should pay.

I guess I should use this tree:
     git://git.kernel.org/pub/scm/linux/kernel/git/jirislaby/linux-stable.git
and apply it on tag v3.14.4?

>
>Thanks.

-- 
Richard Yang
Help you, Help me
