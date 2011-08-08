From: frank.blaschka@de.ibm.com
Subject: [patch 00/13] s390: network patches for net-next
Date: Mon, 08 Aug 2011 13:33:46 +0200
Message-ID: <20110808113346.516293249@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([194.196.100.167]:33050 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753157Ab1HHLfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 07:35:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

this patch set contains s390 network patches for net-next.
Non of the patches touch drivers/net.
There are 2 qeth patches:

shortlog:

Ursula Braun (1)
qeth: do not apply priority queuing to HiperSockets

Frank Blaschka (1)
qeth: l3 ipv6 vlan not working on shared OSA chpid

And the respin of the af_iucv HiperSockets transport feature
(I sent out two week ago for review):

Following patch set implements a new feature to use HiperSockets
as a transport mechanism for the af_iucv address family. Basic
design idea is: The current transport mechanism for af_iucv (iucv)
is only available on VM. HiperSockets provide similar capabilities
as iucv and are available on LPAR. There is guaranty for data
integrity, in order delivery and delivery acknowledgment. A new
HiperSockets feature is exploited to support
flow control/congestion management. For this it is nearby to extend
af_iucv address family to use HiperSockets transport.

shortlog:

Einar Lueck (4)
qdio: support asynchronous delivery of storage blocks
qdio: support forced signal adapter indications
qeth: exploit asynchronous delivery of storage blocks
qeth: support forced signal adapter indications

Ursula Braun (3)
iucv: kernel option for z/VM IUCV and HiperSockets
af_iucv: cleanup - use iucv_sk(sk) early
af_iucv: add HiperSockets transport

Frank Blaschka (4)
iucv: introduce loadable iucv interface
af_iucv: use loadable iucv interface
if_ether: add new Ethernet Protocol ID for af_iucv
qeth: add support for af_iucv HiperSockets transport

Thanks,
        Frank

