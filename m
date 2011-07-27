From: frank.blaschka@de.ibm.com
Subject: [patch 00/11] [RFC] s390: af_iucv traffic over HiperSockets transport
Date: Wed, 27 Jul 2011 18:12:42 +0200
Message-ID: <20110727161242.018577444@de.ibm.com>
To: netdev@vger.kernel.org, linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([194.196.100.161]:49115 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754584Ab1G0QNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2011 12:13:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

Thanks for review and comments,
        Frank
