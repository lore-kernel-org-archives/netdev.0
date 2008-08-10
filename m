From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Sun, 10 Aug 2008 10:19:35 +0100
Message-ID: <20080810101935.5c8e8e9a@lxorguk.ukuu.org.uk>
References: <200807300019.m6U0JkdY012558@localhost.localdomain>
	<aday73jxdfs.fsf@cisco.com>
	<200807311752.00911.divy@chelsio.com>
	<200808071145.03848.divy@chelsio.com>
	<489C8BEB.8060001@opengridcomputing.com>
	<489CC58D.4010606@pobox.com>
	<adazlnlzc60.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Steve Wise <swise@opengridcomputing.com>, davem@davemloft.net,
	Divy Le Ray <divy@chelsio.com>, Karen Xie <kxie@chelsio.com>,
	netdev@vger.kernel.org, open-iscsi@googlegroups.com,
	michaelc@cs.wisc.edu, daisyc@us.ibm.com, wenxiong@us.ibm.com,
	bhua@us.ibm.com, Dimitrios Michailidis <dm@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>,
	linux-scsi <linux-scsi@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Roland Dreier <rdreier@cisco.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <adazlnlzc60.fsf@cisco.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>  - It doesn't work in theory, because the suggestion (I guess) is that
>    the iSCSI HBA has its own MAC and IP and behaves like a separate

The iSCSI HBA is its own system - that is the root of the problem.

>    system.  But this means that to start with the HBA needs its own ARP,
>    ICMP, routing, etc interface, which means we need some (probably new)
>    interface to configure all of this.  And then it doesn't work in lots

Its another system so surely SNMP ;)

More seriously I do think iSCSI is actually a subtly special case of TOE.
Most TOE disintegrates under carefully chosen "malicious" workloads
because of the way it is optimised, and the lack of security integration
ranges can be very very dangeorus. A pure iSCSI connection is generally
private, single purpose and really is the classic application of "pigs fly
given enough thrust" - which is the only way to make the pig in question
(iSCSI) work properly.





