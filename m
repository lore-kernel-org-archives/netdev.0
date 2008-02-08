From: Frank.Blaschka@de.ibm.com
Subject: [patch 0/2] s390: new qeth driver for 2.6.25
Date: Fri, 08 Feb 2008 15:09:59 +0100
Message-ID: <20080208140959.259912000@de.ibm.com>
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:38119 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755978AbYBHOPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 09:15:36 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.13.8/8.13.8) with ESMTP id m18EFZ0M382012
	for <netdev@vger.kernel.org>; Fri, 8 Feb 2008 14:15:35 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m18EFZWo2293860
	for <netdev@vger.kernel.org>; Fri, 8 Feb 2008 15:15:35 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m18EFZCN029793
	for <netdev@vger.kernel.org>; Fri, 8 Feb 2008 15:15:35 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--

Jeff,

the following patch set is intended for 2.6.25. It contains a new
qeth device driver implementation separating the layer 2 from the
layer 3 functions. There are also some new functions and bug
fixes. Kconfig and Makefile apply on top of the latest patch Ursula
Braun send for ctc.

Regards, Frank Blaschka
-- 
