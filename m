From: Jens Osterkamp <jens@de.ibm.com>
Subject: [patch 0/2] spidernet : two important bugfixes
Date: Thu, 13 Jul 2006 11:53:47 +0200
Message-ID: <200607131153.47572.jens@de.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org, arndb@de.ibm.com,
	maxim@de.ibm.com, utz.bacher@de.ibm.com, seg@us.ibm.com,
	jklewis@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:33549 "EHLO
	mtagate2.de.ibm.com") by vger.kernel.org with ESMTP id S932429AbWGMJy2
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jul 2006 05:54:28 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.6/8.13.6) with ESMTP id k6D9sP8S163886
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 13 Jul 2006 09:54:27 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k6D9vL6Z122966
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 13 Jul 2006 11:57:21 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k6D9sNW4007803
	for <netdev@vger.kernel.org>; Thu, 13 Jul 2006 11:54:24 +0200
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset contains two bugfixes, one fixes a bug in the
code clearing out the sequencer ram at startup. The other is
a fix for the tx queue stopping to send packets in heavy load
situations.

Please consider these for inclusion into 2.6.18.

--

