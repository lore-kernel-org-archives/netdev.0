From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 00/14] replace __inline__ by inline in net code
Date: Wed, 06 Feb 2008 10:14:05 +0100
Message-ID: <20080206091405.581849582@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:19754 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760314AbYBFJ0U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 04:26:20 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id m169QJ5K079974
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 09:26:19 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m169QIlW2162876
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 10:26:18 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m169QICL032683
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 10:26:18 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patchset replaces all occurences of __inline__
by inline and make some minor coding style fixes.

It touches:
  . net/* files
  . include/net/* files
  . include/linux/* files (only the ones related to the network)

The patchset touches a lot of files and that can probably increase
the patch conflict probability, but I have this patchset since a 
few days, I didn't noticed any problem when updating net-2.6 and I
hope that will be still the case.
IMHO, it is the right moment to send this patch out, since net-2.6.25
is closed and net-2.6.26 is not yet opened.

-- 
