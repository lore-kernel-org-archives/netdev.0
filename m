From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Sun, 10 Aug 2008 08:49:32 -0400
Message-ID: <489EE3DC.9060202@pobox.com>
References: <200807300019.m6U0JkdY012558@localhost.localdomain>	<aday73jxdfs.fsf@cisco.com>	<200807311752.00911.divy@chelsio.com>	<200808071145.03848.divy@chelsio.com>	<489C8BEB.8060001@opengridcomputing.com>	<489CC58D.4010606@pobox.com>	<adazlnlzc60.fsf@cisco.com> <20080810101935.5c8e8e9a@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <rdreier@cisco.com>,
	Steve Wise <swise@opengridcomputing.com>, davem@davemloft.net,
	Divy Le Ray <divy@chelsio.com>, Karen Xie <kxie@chelsio.com>,
	netdev@vger.kernel.org, open-iscsi@googlegroups.com,
	michaelc@cs.wisc.edu, daisyc@us.ibm.com, wenxiong@us.ibm.com,
	bhua@us.ibm.com, Dimitrios Michailidis <dm@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>,
	linux-scsi <linux-scsi@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40609 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753447AbYHJMtu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Aug 2008 08:49:50 -0400
In-Reply-To: <20080810101935.5c8e8e9a@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alan Cox wrote:
>>  - It doesn't work in theory, because the suggestion (I guess) is that
>>    the iSCSI HBA has its own MAC and IP and behaves like a separate
> 
> The iSCSI HBA is its own system - that is the root of the problem.

Indeed.

Just like with TOE, from the net stack's point of view, an iSCSI HBA is 
essentially a wholly asynchronous remote system [with a really fast 
communication bus like PCI Express].

As such, the task becomes updating the net stack such that 
formerly-private resources are now shared with an independent, external 
system...  with all the complexity, additional failure modes, and 
additional security complications that come along with that.

	Jeff


